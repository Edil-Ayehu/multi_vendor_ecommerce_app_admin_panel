import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme'),
              subtitle: const Text('Change app appearance'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Implement theme settings
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Implement notification settings
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security'),
              subtitle: const Text('Change password and security settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Implement security settings
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('App information and version'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Show about dialog
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
          ),
        ],
      ),
    );
  }
}