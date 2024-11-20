import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';

class ManageProductsScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Manage Products', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(
              child: Text('No products found'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productData = products[index].data() as Map<String, dynamic>;
              final createdAt = (productData['createdAt'] as Timestamp?)?.toDate();
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          (productData['images'] as List<dynamic>?)?.isNotEmpty == true
                              ? productData['images'][0]
                              : 'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  title: Text(productData['name'] ?? 'N/A'),
                  subtitle: Text('\$${productData['price']?.toStringAsFixed(2) ?? '0.00'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
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
                                    _adminService.removeProduct(products[index].id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${productData['category'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text('Description: ${productData['description'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Text(' ${productData['averageRating']?.toStringAsFixed(1) ?? '0.0'}'),
                              Text(' (${productData['totalReviews'] ?? 0} reviews)'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Stock: ${productData['stock'] ?? 0}',
                            style: TextStyle(
                              color: (productData['stock'] ?? 0) > 0 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                          ),
                          if (createdAt != null) ...[
                            const SizedBox(height: 8),
                            Text('Created: ${DateFormat('MMM d, yyyy').format(createdAt)}'),
                          ],
                          const SizedBox(height: 8),
                          if (productData['images'] != null) ...[
                            const Text('Product Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (productData['images'] as List).length,
                                itemBuilder: (context, imageIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        productData['images'][imageIndex],
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}