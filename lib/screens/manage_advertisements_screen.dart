import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:shimmer/shimmer.dart';

class ManageAdvertisementsScreen extends StatefulWidget {
  const ManageAdvertisementsScreen({super.key});

  @override
  State<ManageAdvertisementsScreen> createState() =>
      _ManageAdvertisementsScreenState();
}

class _ManageAdvertisementsScreenState extends State<ManageAdvertisementsScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;
  String? selectedAdId;
  int currentImageIndex = 0;
  int currentPage = 1;
  final int adsPerPage = 25;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black),
        ),
        title: Text(
          'Manage Advertisements',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 2,
          indicatorColor: Theme.of(context).colorScheme.primary,
          dividerColor: Colors.transparent,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
          tabs: [
            Tab(
              height: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LineIcons.alternateExchange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Ads',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              height: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LineIcons.history,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expired Ads',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAllAdvertisements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildShimmerAdsList(),
                _buildShimmerAdsList(),
              ],
            );
          }

          final allAds = snapshot.data!.docs;
          
          // If there are no ads at all, show shimmer while loading
          if (allAds.isEmpty) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildShimmerAdsList(),
                _buildShimmerAdsList(),
              ],
            );
          }

          final activeAds = allAds.where((ad) {
            final adData = ad.data() as Map<String, dynamic>;
            final expiryDate = (adData['expiryDate'] as Timestamp).toDate();
            return !expiryDate.isBefore(DateTime.now()) &&
                adData['isActive'] == true;
          }).toList();

          final expiredAds = allAds.where((ad) {
            final adData = ad.data() as Map<String, dynamic>;
            final expiryDate = (adData['expiryDate'] as Timestamp).toDate();
            final isExpired = expiryDate.isBefore(DateTime.now());

            if (isExpired && adData['isActive'] == true) {
              _adminService.toggleAdvertisementStatus(ad.id, false);
            }

            return expiryDate.isBefore(DateTime.now()) ||
                adData['isActive'] == false;
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAdsList(activeAds, isExpired: false),
              _buildAdsList(expiredAds, isExpired: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdsList(List<DocumentSnapshot> ads, {required bool isExpired}) {
    if (ads.isEmpty) {
      // Show shimmer loading instead of "No advertisements" message
      return _buildShimmerAdsList();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust grid count based on screen size
    int getCrossAxisCount() {
      if (screenWidth > 1200) return 5;
      if (screenWidth > 900) return 4;
      if (screenWidth > 600) return 3;
      return 2;
    }

    // Calculate pagination values
    final totalAds = ads.length;
    final totalPages = (totalAds / adsPerPage).ceil();
    final startIndex = (currentPage - 1) * adsPerPage;
    final endIndex =
        startIndex + adsPerPage > totalAds ? totalAds : startIndex + adsPerPage;

    // Get current page ads
    final currentPageAds = ads.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Ads Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getCrossAxisCount(),
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: currentPageAds.length,
            itemBuilder: (context, index) {
              final adData =
                  currentPageAds[index].data() as Map<String, dynamic>;
              return _buildAdCard(currentPageAds[index].id, adData, isExpired);
            },
          ),
        ),
        // Pagination Controls
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Page Button
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1
                      ? () => setState(() => currentPage--)
                      : null,
                  tooltip: 'Previous page',
                ),

                // Page Numbers
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 1; i <= totalPages; i++)
                      if (i == 1 ||
                          i == totalPages ||
                          (i >= currentPage - 1 && i <= currentPage + 1))
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextButton(
                            onPressed: () => setState(() => currentPage = i),
                            style: TextButton.styleFrom(
                              backgroundColor: currentPage == i
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: const Size(32, 32),
                            ),
                            child: Text(
                              '$i',
                              style: TextStyle(
                                color: currentPage == i ? Colors.white : null,
                              ),
                            ),
                          ),
                        )
                      else if (i == 2 || i == totalPages - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('...',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                  ],
                ),

                // Next Page Button
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages
                      ? () => setState(() => currentPage++)
                      : null,
                  tooltip: 'Next page',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAdCard(
      String adId, Map<String, dynamic> adData, bool isExpired) {
    final expiryDate = (adData['expiryDate'] as Timestamp).toDate();
    final isExpiredAd = expiryDate.isBefore(DateTime.now());

    return InkWell(
      onTap: () => _showAdDetails(adData),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                adData['imageUrl'] ?? 'https://via.placeholder.com/400x200',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adData['title'] ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      adData['description'] ?? 'No Description',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          LineIcons.calendar,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d').format(expiryDate),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isExpired ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (!isExpired) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: adData['isActive'] ?? false,
                              onChanged: isExpiredAd
                                  ? null // Disable switch if ad is expired
                                  : (value) {
                                      _adminService.toggleAdvertisementStatus(
                                          adId, value);
                                    },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LineIcons.trash,
                                color: Colors.red, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showDeleteDialog(adId),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String adId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Advertisement',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this advertisement?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              _adminService.removeAdvertisement(adId);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdDetails(Map<String, dynamic> adData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Advertisement Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LineIcons.times),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              // Ad content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          adData['imageUrl'] ??
                              'https://via.placeholder.com/400x200',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        adData['title'] ?? 'No Title',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Status and expiry date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: adData['isActive'] == true
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              adData['isActive'] == true
                                  ? 'Active'
                                  : 'Inactive',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: adData['isActive'] == true
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LineIcons.calendar,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires on: ${DateFormat('MMM d, yyyy').format((adData['expiryDate'] as Timestamp).toDate())}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Description
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        adData['description'] ?? 'No description available',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      if (adData['link'] != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Advertisement Link',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          adData['link'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAdsList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1200
              ? 5
              : MediaQuery.of(context).size.width > 900
                  ? 4
                  : MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 10, // Show 10 shimmer items while loading
        itemBuilder: (context, index) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer image placeholder
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title placeholder
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      // Description placeholder
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const Spacer(),
                      // Date placeholder
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      // Controls placeholder
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32,
                            height: 16,
                            color: Colors.white,
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
