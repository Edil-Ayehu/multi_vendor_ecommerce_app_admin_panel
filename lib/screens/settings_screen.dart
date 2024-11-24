import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/theme_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            title: 'Theme Mode',
            subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
            trailing: Switch.adaptive(
              value: isDarkMode,
              onChanged: (_) => themeService.toggleTheme(),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'Preferences'),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.orange,
                size: 22,
              ),
            ),
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // Implement notification settings
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.security_outlined,
                color: Colors.blue,
                size: 22,
              ),
            ),
            title: 'Security',
            subtitle: 'Change password and security settings',
            onTap: () {
              // Implement security settings
            },
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'About'),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.purple,
                size: 22,
              ),
            ),
            title: 'App Information',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'E-commerce Admin Panel',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.shopping_cart),
                children: [
                  const Text('A multi-vendor e-commerce admin panel'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required Widget leading,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
