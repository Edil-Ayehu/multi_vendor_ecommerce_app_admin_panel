import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'package:collection/collection.dart';
import 'dart:math' show min;

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

  // Add pagination variables
  int currentPage = 1;
  final int ordersPerPage = 18;

  // Create a map of keys for each tab
  final Map<String?, GlobalKey> _pageKeys = {
    null: GlobalKey(), // All orders
    'pending': GlobalKey(),
    'processing': GlobalKey(),
    'shipped': GlobalKey(),
    'delivered': GlobalKey(),
    'cancelled': GlobalKey(),
  };

  // Add a map to store current page for each tab
  final Map<String?, int> _currentPages = {
    null: 1, // All orders
    'pending': 1,
    'processing': 1,
    'shipped': 1,
    'delivered': 1,
    'cancelled': 1,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Don't reset the page when changing tabs
        currentPage =
            _currentPages[_getStatusForIndex(_tabController.index)] ?? 1;
      });
    });
  }

  // Helper method to get status for tab index
  String? _getStatusForIndex(int index) {
    switch (index) {
      case 0:
        return null; // All orders
      case 1:
        return 'pending';
      case 2:
        return 'processing';
      case 3:
        return 'shipped';
      case 4:
        return 'delivered';
      case 5:
        return 'cancelled';
      default:
        return null;
    }
  }

  void _updatePage(int newPage, String? status) {
    setState(() {
      _currentPages[status] = newPage;
      currentPage = newPage;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: const BoxDecoration(),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                  tabs: [
                    _buildTab('All', LineIcons.shoppingBag, Colors.blue, 0,
                        constraints.maxWidth / 6),
                    _buildTab('Pending', LineIcons.clock, Colors.orange, 1,
                        constraints.maxWidth / 6),
                    _buildTab('Processing', LineIcons.spinner, Colors.blue, 2,
                        constraints.maxWidth / 6),
                    _buildTab('Shipped', LineIcons.truck, Colors.purple, 3,
                        constraints.maxWidth / 6),
                    _buildTab('Delivered', LineIcons.checkCircle, Colors.green,
                        4, constraints.maxWidth / 6),
                    _buildTab('Cancelled', LineIcons.times, Colors.red, 5,
                        constraints.maxWidth / 6),
                  ],
                );
              },
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

          // Store orders in a variable to maintain consistency
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

  Widget _buildTab(
      String title, IconData icon, Color color, int index, double width) {
    final isSelected = _tabController.index == index;

    return Tab(
      height: 56,
      child: SizedBox(
        width: width - 8,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? color
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? color
                        : Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersView(
      List<DocumentSnapshot> orders, String? status, bool isSmallScreen) {
    // Filter orders based on status
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
            Icon(LineIcons.shoppingCart,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No ${status ?? ''} orders found',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    // Calculate pagination values
    final totalOrders = filteredOrders.length;
    final totalPages = (totalOrders / ordersPerPage).ceil();
    final currentPageForStatus = _currentPages[status] ?? 1;

    final startIndex = (currentPageForStatus - 1) * ordersPerPage;
    final endIndex = min(startIndex + ordersPerPage, totalOrders);
    final currentPageOrders = filteredOrders.sublist(startIndex, endIndex);

    return Column(
      key: _pageKeys[status],
      children: [
        Expanded(
          child: Row(
            children: [
              if (selectedOrderId != null && isSmallScreen)
                // Full screen details for small screens
                Expanded(
                  child: _buildOrderDetailsView(filteredOrders),
                )
              else
                // Normal layout
                Expanded(
                  flex: 3,
                  child: _buildOrdersList(currentPageOrders),
                ),

              // Show details panel only on larger screens
              if (selectedOrderId != null && !isSmallScreen) ...[
                Container(width: 1, color: Colors.grey[300]),
                Expanded(
                  flex: 2,
                  child: _buildOrderDetailsPanel(filteredOrders),
                ),
              ],
            ],
          ),
        ),
        // Show pagination only when order list is visible
        if (totalPages > 1 && (selectedOrderId == null || !isSmallScreen))
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPageForStatus > 1
                      ? () => _updatePage(currentPageForStatus - 1, status)
                      : null,
                ),
                const SizedBox(width: 16),
                Text(
                  'Page $currentPageForStatus of $totalPages',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPageForStatus < totalPages
                      ? () => _updatePage(currentPageForStatus + 1, status)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOrderDetailsView(List<DocumentSnapshot> orders) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black),
          onPressed: () => setState(() => selectedOrderId = null),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetailsContent(orders),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(List<DocumentSnapshot> orders) {
    // Find the selected order
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

    return _buildOrderDetails(context, orderData, items, selectedOrder.id);
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildOrderDetailsContent(orders),
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
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Summary Card
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderId.substring(0, 8)}',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(
                            (orderData['createdAt'] as Timestamp).toDate()),
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
                  _buildStatusChip(orderData['status'] ?? 'pending'),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),

        // Items Section
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items (${items.length})',
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
                ),
                const Divider(height: 1, color: Colors.grey),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: index != items.length - 1
                            ? Border(
                                bottom: BorderSide(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.1),
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildProductImage(item['image']),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? 'Unknown Product',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['quantity']} × \$${item['price']?.toStringAsFixed(2)}',
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Status Update Section
        SizedBox(height: isSmallScreen ? 16 : 24),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusButton(
                          context, orderId, 'pending', orderData['status']),
                      const SizedBox(width: 8),
                      _buildStatusButton(
                          context, orderId, 'processing', orderData['status']),
                      const SizedBox(width: 8),
                      _buildStatusButton(
                          context, orderId, 'shipped', orderData['status']),
                      const SizedBox(width: 8),
                      _buildStatusButton(
                          context, orderId, 'delivered', orderData['status']),
                      const SizedBox(width: 8),
                      _buildStatusButton(
                          context, orderId, 'cancelled', orderData['status']),
                    ],
                  ),
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

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 50,
          height: 50,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        LineIcons.image,
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }
}
