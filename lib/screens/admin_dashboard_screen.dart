import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/analytics_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_advertisements_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_orders_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_users_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_products_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/settings_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/sign_in_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildAdminDrawer(context),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _adminService.getPlatformAnalytics(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatisticsGrid(context, data),
                  const SizedBox(height: 24),
                  _buildRecentActivities(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.background,
      title: Text(
        'Dashboard',
        style: GoogleFonts.poppins(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.bell),
          onPressed: () {},
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 1200 ? 1.5 : 1.3,
          children: [
            _buildStatCard(
              context,
              'Total Users',
              data['totalUsers'].toString(),
              LineIcons.users,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Total Products',
              data['totalProducts'].toString(),
              LineIcons.shoppingBag,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'Total Orders',
              data['totalOrders'].toString(),
              LineIcons.shoppingCart,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              'Revenue',
              '\$${data['totalRevenue'].toString()}',
              LineIcons.moneyBill,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentOrders(context)),
              const SizedBox(width: 24),
              Expanded(child: _buildRecentUsers(context)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildRecentOrders(context),
              const SizedBox(height: 24),
              _buildRecentUsers(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
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

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(LineIcons.userShield, size: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: LineIcons.home,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            icon: LineIcons.users,
            title: 'Manage Users',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: LineIcons.shoppingBag,
            title: 'Manage Products',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: LineIcons.shoppingCart,
            title: 'Manage Orders',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: LineIcons.ad,
            title: 'Manage Ads',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const ManageAdvertisementsScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: LineIcons.alternateSignOut,
            title: 'Sign Out',
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(LineIcons.angleRight, size: 18),
                  label: const Text('View All'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageOrdersScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _adminService.getRecentOrders(limit: 10),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!.docs;
                if (orders.isEmpty) {
                  return const Center(child: Text('No recent orders'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const DottedDivider(),
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Order #${orders[index].id.substring(0, 8)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy').format(
                          (order['createdAt'] as Timestamp).toDate(),
                        ),
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: Text(
                        '\$${order['total']?.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsers(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Users',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(LineIcons.angleRight, size: 18),
                  label: const Text('View All'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageUsersScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _adminService.getRecentUsers(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return const Center(child: Text('No recent users'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const DottedDivider(),
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          user['profileImage'] ??
                              'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                        ),
                      ),
                      title: Text(
                        user['fullName'] ?? 'N/A',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        user['email'] ?? 'N/A',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
