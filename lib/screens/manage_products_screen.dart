import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/widgets/dotted_divider.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final AdminService _adminService = AdminService();
  String? selectedProductId;
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Adjust grid count based on screen size and whether details are shown
    int getCrossAxisCount() {
      if (isSmallScreen) return 2;
      if (screenWidth > 1200) {
        return selectedProductId != null ? 3 : 5;
      }
      if (screenWidth > 800) {
        return selectedProductId != null ? 2 : 4;
      }
      return 2;
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

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          // For small screens, show either the grid or the details
          if (isSmallScreen && selectedProductId != null) {
            return _buildProductDetails(
              products.firstWhere((doc) => doc.id == selectedProductId),
            );
          }

          // For larger screens, show split view
          return Row(
            children: [
              // Products Grid with Filter
              Expanded(
                flex: selectedProductId != null ? 3 : 5,
                child: Column(
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
                            items:
                                _getUniqueCategories(products).map((category) {
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: getCrossAxisCount(),
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.where((doc) {
                            if (selectedCategory == null) return true;
                            final productData =
                                doc.data() as Map<String, dynamic>;
                            return productData['category'] == selectedCategory;
                          }).length,
                          itemBuilder: (context, index) {
                            final filteredProducts = products.where((doc) {
                              if (selectedCategory == null) return true;
                              final productData =
                                  doc.data() as Map<String, dynamic>;
                              return productData['category'] ==
                                  selectedCategory;
                            }).toList();
                            final productData = filteredProducts[index].data()
                                as Map<String, dynamic>;
                            return _buildProductCard(
                                filteredProducts[index].id, productData);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Product Details Panel (only for larger screens)
              if (selectedProductId != null && !isSmallScreen) ...[
                Container(width: 1, color: Colors.grey[300]), // Divider
                Expanded(
                  flex: 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: _buildProductDetails(
                      products.firstWhere((doc) => doc.id == selectedProductId),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> productData) {
    final isSelected = productId == selectedProductId;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected && !isSmallScreen
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => setState(() => selectedProductId = productId),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  (productData['images'] as List<dynamic>?)?.isNotEmpty == true
                      ? productData['images'][0]
                      : 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${productData['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(
                            ' ${productData['averageRating']?.toStringAsFixed(1) ?? '0.0'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(DocumentSnapshot product) {
    final productData = product.data() as Map<String, dynamic>;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Calculate average rating
    double calculateAverageRating() {
      final reviews = (productData['reviews'] as List<dynamic>?) ?? [];
      if (reviews.isEmpty) return 0.0;
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += (review['rating'] as num?)?.toDouble() ?? 0.0;
      }
      return totalRating / reviews.length;
    }

    final averageRating = calculateAverageRating();

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back/close button and actions
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                  IconButton(
                    icon: Icon(
                      isSmallScreen ? Icons.arrow_back : Icons.close,
                      size: isSmallScreen ? 24 : 20,
                    ),
                    onPressed: () => setState(() => selectedProductId = null),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stock: ${productData['stock'] ?? 0}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete Product',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showDeleteDialog(product.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Product Images Carousel
            if (productData['images'] != null) ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (productData['images'] as List).length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: isSmallScreen ? screenWidth - 48 : 400,
                      child: Image.network(
                        productData['images'][index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Product Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData['name'] ?? 'N/A',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${productData['price']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                // '${productData['averageRating']?.toStringAsFixed(1) ?? '0.0'}',
                                averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description Section
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        productData['description'] ??
                            'No description available',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Product Details
                    Text(
                      'Product Details',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        'Category', productData['category'] ?? 'N/A'),
                    const DottedDivider(),
                    _buildDetailRow(
                        'Stock', productData['stock']?.toString() ?? '0'),
                    if (productData['brand'] != null) ...[
                      const DottedDivider(),
                      _buildDetailRow('Brand', productData['brand']),
                    ],
                    if (productData['sku'] != null) ...[
                      const DottedDivider(),
                      _buildDetailRow('SKU', productData['sku']),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildReviewsSection(productData),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(Map<String, dynamic> productData) {
    final reviews = (productData['reviews'] as List<dynamic>?) ?? [];

    // Calculate average rating
    double calculateAverageRating() {
      if (reviews.isEmpty) return 0.0;
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += (review['rating'] as num?)?.toDouble() ?? 0.0;
      }
      return totalRating / reviews.length;
    }

    final averageRating = calculateAverageRating();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 18,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ' (${reviews.length})',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const DottedDivider(),
            itemBuilder: (context, index) {
              final review = reviews[index] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                review['userImage'] ??
                                    'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                              ),
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['userName'] ?? 'Anonymous',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                ),
                                Text(
                                  _formatDate(review['createdAt']),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                    if (review['comment'] != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        review['comment'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
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
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _adminService.removeProduct(productId);
              setState(() => selectedProductId = null);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
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
