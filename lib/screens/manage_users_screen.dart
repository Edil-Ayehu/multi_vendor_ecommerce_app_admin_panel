import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ManageUsersScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Customers',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_rounded,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Vendors',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
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
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: GoogleFonts.poppins(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            return _buildUserCard(context, userData, users[index].id);
          },
        );
      },
    );
  }

  Widget _buildUserCard(
      BuildContext context, Map<String, dynamic> userData, String userId) {
    final bool isBlocked = userData['isBlocked'] ?? false;
    final DateTime createdAt = (userData['createdAt'] as Timestamp).toDate();
    final bool isVendor = userData['role'] == 'vendor';
    final Map<String, dynamic> shippingAddress =
        isVendor ? {} : (userData['shippingAddress'] ?? {});

    return Hero(
      tag: 'user-$userId',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: isVendor
                ? _buildVendorTile(context, userData, isBlocked, userId)
                : _buildCustomerExpansionTile(
                    context, userData, isBlocked, shippingAddress, userId),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorTile(BuildContext context, Map<String, dynamic> userData,
      bool isBlocked, String userId) {
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

  Widget _buildCustomerExpansionTile(
    BuildContext context,
    Map<String, dynamic> userData,
    bool isBlocked,
    Map<String, dynamic> shippingAddress,
    String userId,
  ) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.all(16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      title: Row(
        children: [
          Expanded(
            child: Column(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Customer',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: !isBlocked,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) =>
                _adminService.toggleUserStatus(userId, !value),
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
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Shipping Address',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (shippingAddress.isNotEmpty) ...[
          _buildAddressInfo(shippingAddress, context),
        ] else ...[
          Text(
            'No shipping address provided',
            style: GoogleFonts.poppins(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
        if (userData['location'] != null) ...[
          const SizedBox(height: 16),
          Text(
            'Current Location',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.location_on_outlined,
            userData['location'],
            context,
          ),
        ],
      ],
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
}
