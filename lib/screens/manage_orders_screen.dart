import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final AdminService _adminService = AdminService();
  String? selectedOrderId;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black),
        ),
        title: Text(
          'Manage Orders',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _adminService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LineIcons.shoppingCart,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
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

          // For small screens, show either the list or the details
          if (isSmallScreen && selectedOrderId != null) {
            final selectedOrder =
                orders.firstWhere((doc) => doc.id == selectedOrderId);
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => selectedOrderId = null),
                    ),
                    title: Text(
                      'Order Details',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildOrderDetails(
                      context,
                      selectedOrder.data() as Map<String, dynamic>,
                      List<Map<String, dynamic>>.from((selectedOrder.data()
                              as Map<String, dynamic>)['items'] ??
                          []),
                      selectedOrder.id,
                    ),
                  ),
                ],
              ),
            );
          }

          // For larger screens, show split view
          return Row(
            children: [
              // Orders List
              Expanded(
                flex: 3,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final orderData =
                        orders[index].data() as Map<String, dynamic>;
                    final createdAt =
                        (orderData['createdAt'] as Timestamp).toDate();

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () =>
                            setState(() => selectedOrderId = orders[index].id),
                        selected: selectedOrderId == orders[index].id,
                        selectedTileColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LineIcons.shoppingBag,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              'Order #${orders[index].id.substring(0, 8)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(orderData['status'] ?? 'pending'),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('MMM d, yyyy • h:mm a')
                                  .format(createdAt),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${orderData['total']?.toStringAsFixed(2) ?? '0.00'}',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Order Details Panel (only for larger screens)
              if (selectedOrderId != null && !isSmallScreen) ...[
                Container(width: 1, color: Colors.grey[300]), // Divider
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Close button header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Details',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LineIcons.times),
                              onPressed: () =>
                                  setState(() => selectedOrderId = null),
                              tooltip: 'Close details',
                            ),
                          ],
                        ),
                      ),
                      // Order details content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: _buildOrderDetails(
                              context,
                              orders
                                  .firstWhere(
                                      (doc) => doc.id == selectedOrderId)
                                  .data() as Map<String, dynamic>,
                              List<Map<String, dynamic>>.from((orders
                                          .firstWhere((doc) =>
                                              doc.id == selectedOrderId)
                                          .data()
                                      as Map<String, dynamic>)['items'] ??
                                  []),
                              selectedOrderId!,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderDetails(
    BuildContext context,
    Map<String, dynamic> orderData,
    List<Map<String, dynamic>> items,
    String orderId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildStatusChip(orderData['status'] ?? 'pending'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  LineIcons.calendar,
                  'Order Date',
                  DateFormat('MMM d, yyyy • h:mm a')
                      .format((orderData['createdAt'] as Timestamp).toDate()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Customer Information Card
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(orderData['userId'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading customer data');
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            if (userData == null) {
              return const Text('Customer not found');
            }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          backgroundImage: userData['profileImage'] != null
                              ? NetworkImage(userData['profileImage'])
                              : null,
                          child: userData['profileImage'] == null
                              ? Icon(
                                  LineIcons.user,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['fullName'] ?? 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userData['email'] ?? 'N/A',
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Customer Information Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping Details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  LineIcons.mapMarker,
                  'Shipping Address',
                  '${orderData['shippingAddress'] ?? 'N/A'}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  LineIcons.building,
                  'City',
                  orderData['city'] ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  LineIcons.envelope,
                  'ZIP Code',
                  orderData['zipCode'] ?? 'N/A',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Order Items Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Items',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'] ?? 'https://via.placeholder.com/50',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['productName'] ?? 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quantity: ${item['quantity']} × \$${item['price']?.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
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
                        Text(
                          '\$${(item['quantity'] * (item['price'] ?? 0)).toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${orderData['total']?.toStringAsFixed(2) ?? '0.00'}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Status Update Buttons
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusButtons(context, orderId, orderData['status']),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = LineIcons.clock;
        break;
      case 'processing':
        color = Colors.blue;
        icon = LineIcons.spinner;
        break;
      case 'shipped':
        color = Colors.purple;
        icon = LineIcons.truck;
        break;
      case 'delivered':
        color = Colors.green;
        icon = LineIcons.checkCircle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = LineIcons.times;
        break;
      default:
        color = Colors.grey;
        icon = LineIcons.question;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
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

  Widget _buildStatusButtons(
      BuildContext context, String orderId, String currentStatus) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatusButton(context, orderId, 'processing', currentStatus),
        _buildStatusButton(context, orderId, 'shipped', currentStatus),
        _buildStatusButton(context, orderId, 'delivered', currentStatus),
        _buildStatusButton(context, orderId, 'cancelled', currentStatus),
      ],
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String orderId,
    String status,
    String currentStatus,
  ) {
    final isActive = currentStatus.toLowerCase() == status.toLowerCase();
    return ElevatedButton(
      onPressed: isActive
          ? null
          : () => _adminService.updateOrderStatus(orderId, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        foregroundColor:
            isActive ? Colors.white : Theme.of(context).colorScheme.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
