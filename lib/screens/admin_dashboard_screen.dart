import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_advertisements_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_orders_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_users_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_products_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/widgets/admin_drawer.dart';
import 'dart:ui' show Color;
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/theme_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor:
          isDarkMode ? const Color.fromARGB(255, 3, 3, 21) : Colors.grey[100],
      drawer: const AdminDrawer(),
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
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor:
          isDarkMode ? const Color.fromARGB(255, 3, 3, 21) : Colors.grey[100],
      foregroundColor: isDarkMode ? Colors.white : Colors.black,
      title: Text(
        'Dashboard',
        style: GoogleFonts.poppins(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey<bool>(isDarkMode),
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          onPressed: () => themeService.toggleTheme(),
          tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, Map<String, dynamic> data) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 2
                : constraints.maxWidth > 600
                    ? 2
                    : 2;

        final childAspectRatio = constraints.maxWidth > 1200
            ? 1.5
            : constraints.maxWidth > 800
                ? 1.3
                : constraints.maxWidth > 600
                    ? 1.5
                    : 1.5;

        final spacing = constraints.maxWidth > 600 ? 24.0 : 12.0;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 0 : 8.0,
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
            children: [
              _buildStatCard(
                context,
                'Customers',
                data['totalCustomers'].toString(),
                LineIcons.users,
                isDarkMode
                    ? const Color.fromARGB(255, 11, 11, 53)
                    : const Color(0xffC6E7FF),
              ),
              _buildStatCard(
                context,
                'Vendors',
                data['totalVendors'].toString(),
                LineIcons.store,
                isDarkMode
                    ? const Color.fromARGB(255, 11, 11, 53)
                    : const Color(0xffD4F6FF),
              ),
              _buildStatCard(
                context,
                'Products',
                data['totalProducts'].toString(),
                LineIcons.shoppingBag,
                isDarkMode
                    ? const Color.fromARGB(255, 11, 11, 53)
                    : const Color(0xffFBFBFB),
              ),
              _buildStatCard(
                context,
                'Orders',
                data['totalOrders'].toString(),
                LineIcons.shoppingCart,
                isDarkMode
                    ? const Color.fromARGB(255, 11, 11, 53)
                    : const Color(0xffFFDDAE),
              ),
              _buildStatCard(
                context,
                'Active Ads',
                data['activeAds'].toString(),
                LineIcons.ad,
                isDarkMode
                    ? const Color.fromARGB(255, 11, 11, 53)
                    : const Color.fromARGB(255, 190, 159, 236),
              ),
              _buildStatCard(
                context,
                'Revenue',
                '\$${data['totalRevenue'].toString()}',
                LineIcons.moneyBill,
                isDarkMode
                    ? const Color.fromARGB(255, 11, 11, 53)
                    : const Color(0xffFAFFAF),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentOrders(context)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRecentUsers(context)),
                ],
              ),
              const SizedBox(height: 24),
              _buildRecentAds(context),
            ],
          );
        } else if (constraints.maxWidth > 800) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentOrders(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRecentUsers(context)),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecentAds(context),
            ],
          );
        } else {
          return Column(
            children: [
              _buildRecentOrders(context),
              const SizedBox(height: 16),
              _buildRecentUsers(context),
              const SizedBox(height: 16),
              _buildRecentAds(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final cardPadding = screenWidth > 600 ? 24.0 : 16.0;

    final iconSize = screenWidth > 600 ? 24.0 : 20.0;

    final valueSize = screenWidth > 600 ? 28.0 : 20.0;
    final titleSize = screenWidth > 600 ? 14.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth > 600 ? 12 : 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black, size: iconSize),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: titleSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      color:
          isDarkMode ? const Color.fromARGB(255, 11, 11, 53) : Colors.grey[100],
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: isDarkMode
                          ? const Color.fromARGB(255, 211, 211, 241)
                          : Theme.of(context).primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: isDarkMode
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Theme.of(context).primaryColor,
                    ),
                  ),
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
                    final orderTime =
                        (order['createdAt'] as Timestamp).toDate();
                    final status = order['status'] as String? ?? 'pending';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          Text(
                            'Order #${orders[index].id.substring(0, 8)}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(status),
                        ],
                      ),
                      subtitle: Text(
                        'Ordered ${timeago.format(orderTime)}',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        '\$${order['total']?.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: isDarkMode ? Colors.white : Colors.black,
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

  Widget _buildStatusBadge(String status) {
    final statusConfig = {
      'pending': {
        'color': Colors.orange,
        'icon': LineIcons.hourglassStart,
      },
      'processing': {
        'color': Colors.blue,
        'icon': LineIcons.spinner,
      },
      'shipped': {
        'color': Colors.indigo,
        'icon': LineIcons.shippingFast,
      },
      'delivered': {
        'color': Colors.green,
        'icon': LineIcons.checkCircle,
      },
      'cancelled': {
        'color': Colors.red,
        'icon': LineIcons.timesCircle,
      },
    };

    final config =
        statusConfig[status.toLowerCase()] ?? statusConfig['pending'];
    final color = config!['color'] as Color;
    final icon = config['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.capitalize(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      color:
          isDarkMode ? const Color.fromARGB(255, 11, 11, 53) : Colors.grey[100],
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? const Color.fromARGB(255, 211, 211, 241)
                        : Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: isDarkMode
                          ? const Color.fromARGB(255, 7, 7, 48)
                          : Theme.of(context).primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(
                        color: isDarkMode ? Colors.black : Colors.white),
                  ),
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
                    final userTime = (user['createdAt'] as Timestamp).toDate();
                    final userRole = user['role'] as String? ?? 'customer';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          user['profileImage'] ??
                              'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              user['fullName'] ?? 'N/A',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildUserRoleBadge(userRole),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['email'] ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Joined ${timeago.format(userTime)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
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

  Widget _buildUserRoleBadge(String role) {
    final roleConfig = {
      'admin': {
        'color': Colors.purple,
        'icon': LineIcons.userShield,
      },
      'vendor': {
        'color': Colors.blue,
        'icon': LineIcons.store,
      },
      'customer': {
        'color': Colors.green,
        'icon': LineIcons.user,
      },
    };

    final config = roleConfig[role.toLowerCase()] ?? roleConfig['customer'];
    final color = config!['color'] as Color;
    final icon = config['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            role.capitalize(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAds(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;

    return Card(
      elevation: 2,
      color:
          isDarkMode ? const Color.fromARGB(255, 11, 11, 53) : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Advertisements',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth > 600 ? 20 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  icon: Icon(
                    LineIcons.ad,
                    size: screenWidth > 600 ? 24 : 20,
                  ),
                  label: Text(
                    screenWidth > 600 ? 'Manage Ads' : 'View All',
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 14 : 12,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageAdvertisementsScreen()),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth > 600 ? 16 : 12),
            StreamBuilder<QuerySnapshot>(
              stream: _adminService.getRecentAds(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ads = snapshot.data!.docs;
                if (ads.isEmpty) {
                  return const Center(child: Text('No recent advertisements'));
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 1200
                        ? 4
                        : screenWidth > 800
                            ? 3
                            : screenWidth > 600
                                ? 2
                                : 2,
                    childAspectRatio: screenWidth > 1200
                        ? 1.4
                        : screenWidth > 800
                            ? 1.3
                            : screenWidth > 600
                                ? 1.2
                                : 1,
                    crossAxisSpacing: isSmallScreen ? 8 : 16,
                    mainAxisSpacing: isSmallScreen ? 8 : 16,
                  ),
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index].data() as Map<String, dynamic>;
                    final expiryDate = (ad['expiryDate'] as Timestamp).toDate();
                    final isExpired = expiryDate.isBefore(DateTime.now());

                    return Card(
                      elevation: 0,
                      color: isDarkMode
                          ? const Color.fromARGB(255, 11, 11, 53)
                          : Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            child: Image.network(
                              ad['imageUrl'] ??
                                  'https://via.placeholder.com/400x200',
                              height: isSmallScreen ? 120 : 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ad['title'] ?? 'No Title',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: isSmallScreen ? 11 : 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: isSmallScreen ? 2 : 4),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          LineIcons.calendar,
                                          size: isSmallScreen ? 10 : 14,
                                          color: isExpired
                                              ? Colors.red
                                              : Colors.grey[600],
                                        ),
                                        SizedBox(width: isSmallScreen ? 2 : 4),
                                        Expanded(
                                          child: Text(
                                            'Expires ${DateFormat('MMM d').format(expiryDate)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmallScreen ? 9 : 12,
                                              color: isExpired
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 4 : 8,
                                            vertical: isSmallScreen ? 1 : 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ad['isActive'] == true
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                                isSmallScreen ? 8 : 12),
                                          ),
                                          child: Text(
                                            ad['isActive'] == true
                                                ? 'Active'
                                                : 'Inactive',
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmallScreen ? 8 : 11,
                                              color: ad['isActive'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
