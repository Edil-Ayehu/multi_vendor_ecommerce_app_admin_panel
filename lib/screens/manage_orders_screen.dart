import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:collection/collection.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  String? selectedOrderId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: const BoxDecoration(),
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              tabs: [
                _buildTab('All', LineIcons.shoppingBag, Colors.blue, 0),
                _buildTab('Pending', LineIcons.clock, Colors.orange, 1),
                _buildTab('Processing', LineIcons.spinner, Colors.blue, 2),
                _buildTab('Shipped', LineIcons.truck, Colors.purple, 3),
                _buildTab('Delivered', LineIcons.checkCircle, Colors.green, 4),
                _buildTab('Cancelled', LineIcons.times, Colors.red, 5),
              ],
            ),
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

          final allOrders = snapshot.data!.docs;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersView(allOrders, null, isSmallScreen), // All orders
              _buildOrdersView(allOrders, 'pending', isSmallScreen),
              _buildOrdersView(allOrders, 'processing', isSmallScreen),
              _buildOrdersView(allOrders, 'shipped', isSmallScreen),
              _buildOrdersView(allOrders, 'delivered', isSmallScreen),
              _buildOrdersView(allOrders, 'cancelled', isSmallScreen),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, Color color, int index) {
    final isSelected = _tabController.index == index;
    
    return Tab(
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected 
                  ? color 
                  : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? color 
                    : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersView(
      List<DocumentSnapshot> orders, String? status, bool isSmallScreen) {
    // Filter orders by status if specified
    final filteredOrders = status != null
        ? orders.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] ?? 'pending').toLowerCase() ==
                status.toLowerCase();
          }).toList()
        : orders;

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LineIcons.shoppingCart,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status ?? ''} orders found',
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

    // For small screens with selected order
    if (isSmallScreen && selectedOrderId != null) {
      return _buildOrderDetailsView(filteredOrders);
    }

    // Split view for larger screens or order list for small screens
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildOrdersList(filteredOrders),
        ),
        if (selectedOrderId != null && !isSmallScreen) ...[
          Container(width: 1, color: Colors.grey[300]),
          Expanded(
            flex: 2,
            child: _buildOrderDetailsPanel(filteredOrders),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderDetailsView(List<DocumentSnapshot> orders) {
    // Find the selected order or return error widget if not found
    final selectedOrder = orders.firstWhereOrNull(
      (doc) => doc.id == selectedOrderId,
    );

    if (selectedOrder == null) {
      return Center(
        child: Text(
          'Order not found',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      );
    }

    final orderData = selectedOrder.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Back button for mobile view
          Row(
            children: [
              IconButton(
                icon: const Icon(LineIcons.arrowLeft),
                onPressed: () => setState(() => selectedOrderId = null),
              ),
              Text(
                'Back to Orders',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOrderDetails(context, orderData, items, selectedOrder.id),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<DocumentSnapshot> orders) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 160, // Fixed height for each card
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final orderData = order.data() as Map<String, dynamic>;
        final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
        final totalItems = items.fold<int>(
          0,
          (sum, item) => sum + (item['quantity'] as int? ?? 0),
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: InkWell(
            onTap: () => setState(() => selectedOrderId = order.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedOrderId == order.id
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildStatusChip(orderData['status'] ?? 'pending'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Order Info
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a')
                        .format((orderData['createdAt'] as Timestamp).toDate()),
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$totalItems items',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '\$${orderData['total']?.toStringAsFixed(2) ?? '0.00'}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetailsPanel(List<DocumentSnapshot> orders) {
    // Find the selected order or return error widget if not found
    final selectedOrder = orders.firstWhereOrNull(
      (doc) => doc.id == selectedOrderId,
    );

    if (selectedOrder == null) {
      return Center(
        child: Text(
          'Select an order to view details',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      );
    }

    final orderData = selectedOrder.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Add close button header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(LineIcons.times),
                  onPressed: () => setState(() => selectedOrderId = null),
                  tooltip: 'Close details',
                ),
              ],
            ),
          ),
          // Wrap the existing content in Expanded and SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildOrderDetails(
                  context, orderData, items, selectedOrder.id),
            ),
          ),
        ],
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
        // Order Summary
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
                Text(
                  'Order Date: ${DateFormat('MMM d, yyyy • h:mm a').format((orderData['createdAt'] as Timestamp).toDate())}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Order Items
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
                  'Items',
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
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['image'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(LineIcons.image),
                          ),
                        ),
                      ),
                      title: Text(
                        item['name'] ?? 'Unknown Product',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Quantity: ${item['quantity']} × \$${item['price']?.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      trailing: Text(
                        '\$${(item['quantity'] * (item['price'] ?? 0)).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${orderData['total']?.toStringAsFixed(2) ?? '0.00'}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusButton(
                        context, orderId, 'pending', orderData['status']),
                    _buildStatusButton(
                        context, orderId, 'processing', orderData['status']),
                    _buildStatusButton(
                        context, orderId, 'shipped', orderData['status']),
                    _buildStatusButton(
                        context, orderId, 'delivered', orderData['status']),
                    _buildStatusButton(
                        context, orderId, 'cancelled', orderData['status']),
                  ],
                ),
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

  Widget _buildStatusButton(
    BuildContext context,
    String orderId,
    String status,
    String? currentStatus,
  ) {
    final isActive = currentStatus?.toLowerCase() == status.toLowerCase();
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
}
