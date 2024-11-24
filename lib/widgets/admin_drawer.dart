import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_advertisements_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_orders_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_products_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/manage_users_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/settings_screen.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/screens/sign_in_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF1A1A1A) // Dark background
              : Theme.of(context).colorScheme.surface,
          gradient: isDarkMode ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              const Color(0xFF2D2D2D),
            ],
          ) : null,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context,
              icon: Icons.dashboard_rounded,
              title: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.people_alt_rounded,
              title: 'Manage Users',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.inventory_2_rounded,
              title: 'Manage Products',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageProductsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.shopping_bag_rounded,
              title: 'Manage Orders',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.campaign_rounded,
              title: 'Manage Ads',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageAdvertisementsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(
                color: Colors.grey[300],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return DrawerHeader(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode ? [
            const Color(0xFF2E3192), // Dark mode primary
            const Color(0xFF1BFFFF), // Dark mode secondary
          ] : [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: isDarkMode ? [
          BoxShadow(
            color: const Color(0xFF2E3192).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: isDarkMode ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image(
                  image: AssetImage('assets/edil.JPG'),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'E-Shop',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Admin Panel',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isDarkMode ? LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.05),
          ],
        ) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDarkMode 
              ? Theme.of(context).primaryColor.withOpacity(0.9)
              : Theme.of(context).primaryColor,
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white.withOpacity(0.9) : null,
          ),
        ),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minLeadingWidth: 20,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        hoverColor: isDarkMode 
            ? Colors.white.withOpacity(0.1)
            : null,
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sign Out',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
              child: Text(
                'Sign Out',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
