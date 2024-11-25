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

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  String? selectedUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedUserId = null;
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (selectedUserId != null) {
      setState(() {
        selectedUserId = null;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
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
              controller: _tabController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              tabs: [
                Tab(
                  height: 52,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    constraints:
                        BoxConstraints(minWidth: isSmallScreen ? 160 : 260),
                    decoration: BoxDecoration(
                      color: _tabController.index == 0
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _tabController.index == 0
                            ? Colors.blue
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: _tabController.index == 0
                              ? Colors.blue
                              : Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Customers',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _tabController.index == 0
                                ? Colors.blue
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  height: 52,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    constraints:
                        BoxConstraints(minWidth: isSmallScreen ? 160 : 260),
                    decoration: BoxDecoration(
                      color: _tabController.index == 1
                          ? Colors.purple.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _tabController.index == 1
                            ? Colors.purple
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_rounded,
                          size: 20,
                          color: _tabController.index == 1
                              ? Colors.purple
                              : Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vendors',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _tabController.index == 1
                                ? Colors.purple
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withOpacity(0.7),
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
            controller: _tabController,
            children: [
              _buildUsersView(_adminService.getCustomers(), isSmallScreen),
              _buildUsersView(_adminService.getVendors(), isSmallScreen),
            ],
          ),
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
        final isVendorTab = _tabController.index == 1;

        // Sort users by createdAt timestamp (most recent first)
        users.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = (aData['createdAt'] as Timestamp).toDate();
          final bTime = (bData['createdAt'] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });

        if (users.isEmpty) {
          return Center(
            child: Text(
              'No ${isVendorTab ? 'vendors' : 'customers'} found',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          );
        }

        // For small screens, show either the list or the details
        if (isSmallScreen && selectedUserId != null && !isVendorTab) {
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

        return Row(
          children: [
            Expanded(
              flex: selectedUserId != null && !isSmallScreen && !isVendorTab
                  ? 3
                  : 5,
              child: GridView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _calculateCrossAxisCount(
                    MediaQuery.of(context).size.width * 
                    (selectedUserId != null && !isSmallScreen && !isVendorTab ? 0.6 : 1.0)
                  ),
                  childAspectRatio: isSmallScreen ? 0.8 : 0.8,
                  crossAxisSpacing: isSmallScreen ? 8 : 16,
                  mainAxisSpacing: isSmallScreen ? 8 : 16,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  return isVendorTab
                      ? _buildVendorCard(context, userData, users[index].id)
                      : _buildCustomerCard(context, userData, users[index].id);
                },
              ),
            ),
            if (selectedUserId != null && !isSmallScreen && !isVendorTab) ...[
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

  int _calculateCrossAxisCount(double width) {
    if (selectedUserId != null && width > 600) {
      if (width <= 900) return 2;
      if (width <= 1200) return 3;
      return 4;
    }
    
    if (width <= 600) return 2;
    if (width <= 900) return 3;
    if (width <= 1200) return 4;
    return 5;
  }

  Widget _buildCustomerCard(
      BuildContext context, Map<String, dynamic> userData, String userId) {
    final bool isBlocked = userData['isBlocked'] ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selectedUserId == userId
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 40, 98, 139).withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => selectedUserId = userId),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: isSmallScreen ? 30 : 40,
                      backgroundImage: NetworkImage(
                        userData['profileImage'] ??
                            'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
                        decoration: BoxDecoration(
                          color: isBlocked ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: isSmallScreen ? 1.5 : 2,
                          ),
                        ),
                        child: Icon(
                          isBlocked ? Icons.block : Icons.check,
                          size: isSmallScreen ? 8 : 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 8 : 16),
                Text(
                  userData['fullName'] ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 13 : 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  userData['email'] ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 11 : 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Customer',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorCard(
      BuildContext context, Map<String, dynamic> userData, String userId) {
    final bool isBlocked = userData['isBlocked'] ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100.withOpacity(0.3),
              const Color.fromARGB(255, 236, 226, 239),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 30 : 40,
                    backgroundImage: NetworkImage(
                      userData['profileImage'] ??
                          'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
                      decoration: BoxDecoration(
                        color: isBlocked ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: isSmallScreen ? 1.5 : 2,
                        ),
                      ),
                      child: Icon(
                        isBlocked ? Icons.block : Icons.check,
                        size: isSmallScreen ? 8 : 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 16),
              Text(
                userData['fullName'] ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                userData['email'] ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 11 : 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 2 : 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Vendor',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Transform.scale(
                scale: isSmallScreen ? 0.8 : 1.0,
                child: Switch.adaptive(
                  value: !isBlocked,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) =>
                      _adminService.toggleUserStatus(userId, !value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(
      BuildContext context, Map<String, dynamic> userData, String userId) {
    final bool isBlocked = userData['isBlocked'] ?? false;
    final Map<String, dynamic> shippingAddress =
        userData['shippingAddress'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
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
                const SizedBox(height: 16),
                Text(
                  userData['fullName'] ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData['email'] ?? 'N/A',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Switch.adaptive(
                  value: !isBlocked,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) =>
                      _adminService.toggleUserStatus(userId, !value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Customer Information Section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  'Account Status',
                  isBlocked ? 'Blocked' : 'Active',
                  icon: isBlocked
                      ? Icons.block_rounded
                      : Icons.check_circle_rounded,
                  iconColor: isBlocked ? Colors.red : Colors.green,
                ),
                _buildDivider(),
                _buildInfoTile(
                  'Member Since',
                  timeago.format(userData['createdAt'].toDate()),
                  icon: Icons.calendar_today_rounded,
                ),
                if (userData['phone'] != null) ...[
                  _buildDivider(),
                  _buildInfoTile(
                    'Phone',
                    userData['phone'],
                    icon: Icons.phone_rounded,
                  ),
                ],
                if (userData['location'] != null) ...[
                  _buildDivider(),
                  _buildInfoTile(
                    'Location',
                    userData['location'],
                    icon: Icons.location_on_rounded,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Shipping Address Section
          if (shippingAddress.isNotEmpty) ...[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shipping Address',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shippingAddress['street'] != null)
                          _buildAddressLine(
                            'Street',
                            shippingAddress['street'],
                          ),
                        if (shippingAddress['city'] != null) ...[
                          const SizedBox(height: 8),
                          _buildAddressLine(
                            'City',
                            shippingAddress['city'],
                          ),
                        ],
                        if (shippingAddress['state'] != null) ...[
                          const SizedBox(height: 8),
                          _buildAddressLine(
                            'State',
                            shippingAddress['state'],
                          ),
                        ],
                        if (shippingAddress['zipCode'] != null) ...[
                          const SizedBox(height: 8),
                          _buildAddressLine(
                            'ZIP Code',
                            shippingAddress['zipCode'],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value,
      {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }
}
