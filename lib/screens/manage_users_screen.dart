import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final AdminService _adminService = AdminService();
  String? selectedUserId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LineIcons.arrowLeft, color: Colors.black),
          ),
          title: Text(
            'Manage Users',
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            indicatorColor: Theme.of(context).colorScheme.primary,
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
            tabs: [
              Tab(
                height: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Customers',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Tab(
                height: 48,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vendors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersView(_adminService.getCustomers(), isSmallScreen),
            _buildUsersView(_adminService.getVendors(), isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersView(
      Stream<QuerySnapshot> usersStream, bool isSmallScreen) {
    return StreamBuilder<QuerySnapshot>(
      stream: usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        final isVendorTab = DefaultTabController.of(context).index == 1;

        // Sort users by createdAt timestamp (most recent first)
        users.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = (aData['createdAt'] as Timestamp).toDate();
          final bTime = (bData['createdAt'] as Timestamp).toDate();
          return bTime.compareTo(aTime); // Reverse order for most recent first
        });

        if (isVendorTab) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              return _buildVendorTile(context, userData, users[index].id);
            },
          );
        }

        // For small screens, show either the list or the details
        if (isSmallScreen && selectedUserId != null) {
          final selectedUser =
              users.firstWhere((doc) => doc.id == selectedUserId);
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => selectedUserId = null),
                  ),
                  title: const Text('Customer Details'),
                ),
                _buildCustomerDetails(
                  context,
                  selectedUser.data() as Map<String, dynamic>,
                  selectedUser.id,
                ),
              ],
            ),
          );
        }

        // Split view for larger screens
        return Row(
          children: [
            Expanded(
              flex: selectedUserId != null ? 3 : 5,
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: selectedUserId == users[index].id
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      onTap: () =>
                          setState(() => selectedUserId = users[index].id),
                      contentPadding: const EdgeInsets.all(12),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              userData['profileImage'] ??
                                  'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: userData['isBlocked'] == true
                                    ? Colors.red
                                    : Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                userData['isBlocked'] == true
                                    ? Icons.block
                                    : Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['fullName'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Customer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(userData['email'] ?? 'N/A'),
                          const SizedBox(height: 4),
                          Text(
                            'Joined ${timeago.format(userData['createdAt'].toDate())}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedUserId != null && !isSmallScreen) ...[
              Container(width: 1, color: Colors.grey[300]),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => selectedUserId = null),
                        ),
                        title: const Text('Customer Details'),
                      ),
                      _buildCustomerDetails(
                        context,
                        users
                            .firstWhere((doc) => doc.id == selectedUserId)
                            .data() as Map<String, dynamic>,
                        selectedUserId!,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCustomerDetails(
      BuildContext context, Map<String, dynamic> userData, String userId) {
    final bool isBlocked = userData['isBlocked'] ?? false;
    final Map<String, dynamic> shippingAddress =
        userData['shippingAddress'] ?? {};

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  userData['profileImage'] ??
                      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['fullName'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(userData['email'] ?? 'N/A'),
                  ],
                ),
              ),
              Switch.adaptive(
                value: !isBlocked,
                onChanged: (value) =>
                    _adminService.toggleUserStatus(userId, !value),
              ),
            ],
          ),
          const Divider(height: 32),
          // Contact Information
          _buildDetailSection('Contact Information', [
            _buildInfoRow(
                Icons.email_outlined, userData['email'] ?? 'N/A', context),
            if (userData['phone'] != null)
              _buildInfoRow(Icons.phone_outlined, userData['phone'], context),
            _buildInfoRow(
              Icons.access_time,
              'Joined ${timeago.format(userData['createdAt'].toDate())}',
              context,
            ),
          ]),
          const SizedBox(height: 24),
          // Shipping Address
          _buildDetailSection('Shipping Address', [
            if (shippingAddress.isNotEmpty)
              _buildAddressInfo(shippingAddress, context)
            else
              Text(
                'No shipping address provided',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ),
          ]),
          if (userData['location'] != null) ...[
            const SizedBox(height: 24),
            _buildDetailSection('Current Location', [
              _buildInfoRow(
                  Icons.location_on_outlined, userData['location'], context),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildVendorTile(
      BuildContext context, Map<String, dynamic> userData, String userId) {
    final bool isBlocked = userData['isBlocked'] ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            backgroundImage: NetworkImage(
              userData['profileImage'] ??
                  'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isBlocked ? Colors.red : Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Icon(
                isBlocked ? Icons.block : Icons.check,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userData['fullName'] ?? 'N/A',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Vendor',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.email_outlined,
            userData['email'] ?? 'N/A',
            context,
          ),
          if (userData['phone'] != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.phone_outlined,
              userData['phone'],
              context,
            ),
          ],
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.access_time,
            'Joined ${timeago.format(userData['createdAt'].toDate())}',
            context,
          ),
        ],
      ),
      trailing: Switch.adaptive(
        value: !isBlocked,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (value) => _adminService.toggleUserStatus(userId, !value),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInfo(Map<String, dynamic> address, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressRow('Street', address['street'], context),
          if (address['city'] != null) ...[
            const SizedBox(height: 4),
            _buildAddressRow('City', address['city'], context),
          ],
          if (address['state'] != null) ...[
            const SizedBox(height: 4),
            _buildAddressRow('State', address['state'], context),
          ],
          if (address['zipCode'] != null) ...[
            const SizedBox(height: 4),
            _buildAddressRow('ZIP Code', address['zipCode'], context),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String? value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
