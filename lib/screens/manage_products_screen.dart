import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final AdminService _adminService = AdminService();
  String? selectedProductId;
  String? selectedCategory;
  int currentImageIndex = 0;
  int currentPage = 1;
  final int productsPerPage = 25;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Adjust grid count based on screen size
    int getCrossAxisCount() {
      if (isSmallScreen) return 2;
      if (screenWidth > 1200) return 5;
      if (screenWidth > 800) return 4;
      return 3;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        title: const Text('Manage Products',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = snapshot.data!.docs;

          // Filter products based on category
          final filteredProducts = allProducts.where((doc) {
            if (selectedCategory == null) return true;
            final productData = doc.data() as Map<String, dynamic>;
            return productData['category'] == selectedCategory;
          }).toList();

          // Calculate pagination values
          final totalProducts = filteredProducts.length;
          final totalPages = (totalProducts / productsPerPage).ceil();
          final startIndex = (currentPage - 1) * productsPerPage;
          final endIndex = startIndex + productsPerPage > totalProducts
              ? totalProducts
              : startIndex + productsPerPage;

          // Get current page products
          final currentPageProducts =
              filteredProducts.sublist(startIndex, endIndex);

          if (filteredProducts.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return Column(
            children: [
              // Category Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text('Filter by Category'),
                      isExpanded: true,
                      items: _getUniqueCategories(allProducts).map((category) {
                        return DropdownMenuItem(
                          value: category == 'All' ? null : category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              // Products Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: getCrossAxisCount(),
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: currentPageProducts.length,
                  itemBuilder: (context, index) {
                    final productData = currentPageProducts[index].data()
                        as Map<String, dynamic>;
                    return _buildProductCard(
                        currentPageProducts[index].id, productData);
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: TextButton(
                                  onPressed: () =>
                                      setState(() => currentPage = i),
                                  style: TextButton.styleFrom(
                                    backgroundColor: currentPage == i
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    minimumSize: const Size(32, 32),
                                  ),
                                  child: Text(
                                    '$i',
                                    style: TextStyle(
                                      color: currentPage == i
                                          ? Colors.white
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                            else if (i == 2 || i == totalPages - 1)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
        },
      ),
    );
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> productData) {
    return InkWell(
      onTap: () => _showProductDetails(productData),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                (productData['images'] as List?)?.firstOrNull ??
                    'https://via.placeholder.com/400x200',
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
                      productData['name'] ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${(productData['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      productData['description'] ?? 'No Description',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Stock: ${productData['stock'] ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LineIcons.trash,
                              color: Colors.red, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showDeleteDialog(productId),
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
    );
  }

  void _showProductDetails(Map<String, dynamic> productData) {
    // Local variables for dialog
    int dialogImageIndex = 0;
    final PageController pageController = PageController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
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
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Product Details',
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
                  // Product content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Update Image Carousel section
                          if ((productData['images'] as List<dynamic>?)
                                  ?.isNotEmpty ??
                              false) ...[
                            SizedBox(
                              height: 340,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        PageView.builder(
                                          controller: pageController,
                                          itemCount:
                                              (productData['images'] as List)
                                                  .length,
                                          itemBuilder: (context, index) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                productData['images'][index],
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                          onPageChanged: (index) {
                                            setDialogState(() {
                                              dialogImageIndex = index;
                                            });
                                          },
                                        ),
                                        // Navigation Arrows
                                        if ((productData['images'] as List)
                                                .length >
                                            1) ...[
                                          Positioned.fill(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Previous Button
                                                Material(
                                                  color: Colors.black26,
                                                  borderRadius:
                                                      const BorderRadius
                                                          .horizontal(
                                                    right: Radius.circular(25),
                                                  ),
                                                  child: InkWell(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .horizontal(
                                                      right:
                                                          Radius.circular(25),
                                                    ),
                                                    onTap: dialogImageIndex > 0
                                                        ? () {
                                                            setDialogState(() {
                                                              dialogImageIndex--;
                                                              pageController
                                                                  .previousPage(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                curve: Curves
                                                                    .easeInOut,
                                                              );
                                                            });
                                                          }
                                                        : null,
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .horizontal(
                                                          right:
                                                              Radius.circular(
                                                                  25),
                                                        ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      child: Icon(
                                                        Icons
                                                            .arrow_back_ios_new,
                                                        color:
                                                            dialogImageIndex > 0
                                                                ? Colors.white
                                                                : Colors
                                                                    .white38,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Next Button
                                                Material(
                                                  color: Colors.black26,
                                                  borderRadius:
                                                      const BorderRadius
                                                          .horizontal(
                                                    left: Radius.circular(25),
                                                  ),
                                                  child: InkWell(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .horizontal(
                                                      left: Radius.circular(25),
                                                    ),
                                                    onTap: dialogImageIndex <
                                                            (productData['images']
                                                                        as List)
                                                                    .length -
                                                                1
                                                        ? () {
                                                            setDialogState(() {
                                                              dialogImageIndex++;
                                                              pageController
                                                                  .nextPage(
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                curve: Curves
                                                                    .easeInOut,
                                                              );
                                                            });
                                                          }
                                                        : null,
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .horizontal(
                                                          left: Radius.circular(
                                                              25),
                                                        ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      child: Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: dialogImageIndex <
                                                                (productData['images']
                                                                            as List)
                                                                        .length -
                                                                    1
                                                            ? Colors.white
                                                            : Colors.white38,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Updated Page Indicators
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      (productData['images'] as List).length,
                                      (index) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: dialogImageIndex == index
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Title and Category
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  productData['name'] ?? 'No Name',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  productData['category'] ?? 'Uncategorized',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Price and Stock
                          Row(
                            children: [
                              Text(
                                '\$${(productData['price'] ?? 0.0).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Stock: ${productData['stock'] ?? 0}',
                                  style: GoogleFonts.poppins(fontSize: 14),
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
                            productData['description'] ??
                                'No description available',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          if (productData['reviews'] != null) ...[
                            const SizedBox(height: 24),
                            // Reviews Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reviews',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_calculateAverageRating(productData['reviews'] as List<dynamic>?).toStringAsFixed(1)} (${(productData['reviews'] as List<dynamic>?)?.length ?? 0})',
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Reviews List
                            ...(productData['reviews'] as List<dynamic>?)?.map(
                                    (review) => _buildReviewItem(review)) ??
                                [],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  review['userImage'] ?? 'https://via.placeholder.com/50',
                ),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? 'Anonymous',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < (review['rating'] ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review['createdAt']),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (review['comment'] != null) ...[
            const SizedBox(height: 8),
            Text(
              review['comment'],
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
          const DottedDivider(),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      return DateFormat('MMM d, yyyy').format(date.toDate());
    }
    return 'N/A';
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this product?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              _adminService.removeProduct(productId);
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

  List<String> _getUniqueCategories(List<DocumentSnapshot> products) {
    final Set<String> categories = {'All'}.union(
      products
          .map((product) =>
              (product.data() as Map<String, dynamic>)['category'] as String? ??
              'Uncategorized')
          .toSet(),
    );
    return categories.toList()..sort();
  }

  double _calculateAverageRating(List<dynamic>? reviews) {
    if (reviews == null || reviews.isEmpty) return 0.0;

    double totalRating = reviews.fold(0.0, (sum, review) {
      return sum + (review['rating'] ?? 0.0);
    });

    return totalRating / reviews.length;
  }
}

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(
          150 ~/ 2,
          (index) => Expanded(
            child: Container(
              color: index.isEven
                  ? Theme.of(context).dividerColor.withOpacity(0.1)
                  : Colors.transparent,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
