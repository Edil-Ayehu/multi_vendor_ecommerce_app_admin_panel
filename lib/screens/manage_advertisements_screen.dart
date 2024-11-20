import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';

class ManageAdvertisementsScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  ManageAdvertisementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Manage Advertisements', 
            style: TextStyle(color: Colors.white)),
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

          final ads = snapshot.data!.docs;

          if (ads.isEmpty) {
            return const Center(child: Text('No advertisements found'));
          }

          return ListView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final adData = ads[index].data() as Map<String, dynamic>;
              final createdAt = (adData['createdAt'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Advertisement Image
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(adData['imageUrl'] ?? 
                              'https://via.placeholder.com/400x200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adData['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(adData['description'] ?? 'No Description'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                adData['isActive'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: adData['isActive'] == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                adData['isActive'] == true ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: adData['isActive'] == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Created: ${DateFormat('MMM d, yyyy').format(createdAt)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Switch(
                                value: adData['isActive'] ?? false,
                                onChanged: (value) {
                                  _adminService.toggleAdvertisementStatus(
                                    ads[index].id,
                                    value,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Advertisement'),
                                      content: const Text(
                                          'Are you sure you want to delete this advertisement?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _adminService.removeAdvertisement(
                                                ads[index].id);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Delete',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add advertisement functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}