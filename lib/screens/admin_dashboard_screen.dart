import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/analytics_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_advertisements_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_orders_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_users_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_products_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/settings_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _adminService.getPlatformAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatisticsGrid(data),
                const SizedBox(height: 24),
                _buildRecentOrders(),
                const SizedBox(height: 24),
                _buildRecentUsers(),
              ],
            ),
          );
        },
      ),
      drawer: _buildAdminDrawer(context),
    );
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Users',
          data['totalUsers'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Products',
          data['totalProducts'].toString(),
          Icons.shopping_bag,
          Colors.green,
        ),
        _buildStatCard(
          'Total Orders',
          data['totalOrders'].toString(),
          Icons.shopping_cart,
          Colors.orange,
        ),
        _buildStatCard(
          'Revenue',
          '\$${data['totalRevenue'].toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.purple,
        ),
      ],
    );
  }

  // ... existing code ...

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _adminService.getAllOrders().take(5),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderData = orders[index].data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text('Order #${orders[index].id.substring(0, 8)}'),
                    subtitle: Text(
                      'Amount: \$${orderData['totalAmount']?.toStringAsFixed(2)}',
                    ),
                    trailing:
                        _getOrderStatusChip(orderData['status'] ?? 'pending'),
                    onTap: () {
                      // Navigate to order details
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Users',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _adminService.getAllUsers().take(5),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                final userRole = userData['role'] ?? 'customer';

                Color roleColor;
                switch (userRole) {
                  case 'vendor':
                    roleColor = Colors.green;
                    break;
                  case 'admin':
                    roleColor = Colors.red;
                    break;
                  default:
                    roleColor = Colors.blue;
                }

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        userData['profileImage'] ??
                            'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                      ),
                    ),
                    title: Text(userData['fullName'] ?? 'N/A'),
                    subtitle: Text(userData['email'] ?? 'N/A'),
                    trailing: Text(
                      _capitalizeFirstLetter(userRole),
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      LineIcons.shoppingBag,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your e-commerce platform',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Colors.transparent, // Remove border
                    width: 0,
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: 16),
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.home,
                      title: 'Dashboard',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.users,
                      title: 'Users',
                      onTap: () =>
                          _navigateToScreen(context, ManageUsersScreen()),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.shoppingBag,
                      title: 'Products',
                      onTap: () =>
                          _navigateToScreen(context, ManageProductsScreen()),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.shoppingCart,
                      title: 'Orders',
                      onTap: () =>
                          _navigateToScreen(context, ManageOrdersScreen()),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.ad,
                      title: 'Advertisements',
                      onTap: () => _navigateToScreen(
                          context, ManageAdvertisementsScreen()),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.lineChart,
                      title: 'Analytics',
                      onTap: () =>
                          _navigateToScreen(context, AnalyticsScreen()),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: DottedDivider(),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.cog,
                      title: 'Settings',
                      onTap: () =>
                          _navigateToScreen(context, const SettingsScreen()),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: LineIcons.alternateSignOut,
                      title: 'Logout',
                      isDestructive: true,
                      onTap: () => _showLogoutDialog(context),
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

  Widget _getOrderStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'processing':
        color = Colors.blue;
        icon = Icons.hourglass_empty;
        break;
      case 'shipped':
        color = Colors.purple;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      avatar: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title),
        onTap: onTap,
        trailing: isDestructive
            ? Icon(
                LineIcons.alternateSignOut,
                color: Theme.of(context).colorScheme.error,
              )
            : null,
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await FirebaseAuth.instance.signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
