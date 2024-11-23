import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';

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
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Active Ads'),
            Tab(text: 'Expired Ads'),
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
            return const Center(child: CircularProgressIndicator());
          }

          final allAds = snapshot.data!.docs;
          final activeAds = allAds.where((ad) {
            final adData = ad.data() as Map<String, dynamic>;
            final expiryDate = (adData['expiryDate'] as Timestamp).toDate();
            return !expiryDate.isBefore(DateTime.now()) &&
                adData['isActive'] == true;
          }).toList();

          final expiredAds = allAds.where((ad) {
            final adData = ad.data() as Map<String, dynamic>;
            final expiryDate = (adData['expiryDate'] as Timestamp).toDate();
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LineIcons.ad,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isExpired
                  ? 'No expired advertisements'
                  : 'No active advertisements',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust grid count based on screen size
    int getCrossAxisCount() {
      if (screenWidth > 1200) return 5;
      if (screenWidth > 900) return 4;
      if (screenWidth > 600) return 3;
      return 2;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(),
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final adData = ads[index].data() as Map<String, dynamic>;
        return _buildAdCard(ads[index].id, adData, isExpired);
      },
    );
  }

  Widget _buildAdCard(
      String adId, Map<String, dynamic> adData, bool isExpired) {
    final expiryDate = (adData['expiryDate'] as Timestamp).toDate();

    return Card(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 5,
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
                      Text(
                        'Expires on: ',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
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
                            onChanged: (value) {
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
}
