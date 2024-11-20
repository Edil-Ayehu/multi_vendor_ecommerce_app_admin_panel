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
              Tab(
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                text: 'Customers',
              ),
              Tab(
                icon: Icon(
                  Icons.store,
                  color: Colors.black,
                ),
                text: 'Vendors',
              ),
            ],
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
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
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(
            child: Text('No users found'),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userData['profileImage'] ??
                      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y'),
                ),
                title: Text(userData['fullName'] ?? 'N/A'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userData['email'] ?? 'N/A'),
                    Text(
                      'Status: ${userData['isBlocked'] == true ? 'Blocked' : 'Active'}',
                      style: TextStyle(
                        color: userData['isBlocked'] == true
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: !(userData['isBlocked'] ?? false),
                  onChanged: (value) {
                    _adminService.toggleUserStatus(
                      users[index].id,
                      !value,
                    );
                  },
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
