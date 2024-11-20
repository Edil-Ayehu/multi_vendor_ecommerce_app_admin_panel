import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';

class ManageUsersScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Users'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Customers'),
              Tab(text: 'Vendors'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersList(_adminService.getCustomers()),
            _buildUsersList(_adminService.getVendors()),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(Stream<QuerySnapshot> usersStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: usersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(userData['profileImage'] ?? ''),
              ),
              title: Text(userData['fullName'] ?? 'N/A'),
              subtitle: Text(userData['email'] ?? 'N/A'),
              trailing: Switch(
                value: !(userData['isBlocked'] ?? false),
                onChanged: (value) {
                  _adminService.toggleUserStatus(
                    users[index].id,
                    !value,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}