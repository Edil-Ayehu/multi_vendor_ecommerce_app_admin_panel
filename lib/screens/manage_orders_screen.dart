import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';

class ManageOrdersScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title:
            const Text('Manage Orders', style: TextStyle(color: Colors.white)),
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
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final createdAt = (orderData['createdAt'] as Timestamp).toDate();
              final items =
                  List<Map<String, dynamic>>.from(orderData['items'] ?? []);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text('Order #${orders[index].id.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('MMM d, yyyy').format(createdAt)),
                      Text(
                          '\$${orderData['total']?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                  trailing: _buildStatusChip(orderData['status'] ?? 'pending'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${orders[index].id}'),
                          Text('User ID: ${orderData['userId'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          Text('Shipping Address:'),
                          Text('City: ${orderData['city'] ?? 'N/A'}'),
                          Text('Zip Code: ${orderData['zipCode'] ?? 'N/A'}'),
                          const SizedBox(height: 16),
                          const Text('Order Items:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, itemIndex) {
                              final item = items[itemIndex];
                              return ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(item['image'] ??
                                          'https://via.placeholder.com/50'),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                title: Text(item['productName'] ?? 'N/A'),
                                subtitle: Text(
                                    'Quantity: ${item['quantity']} x \$${item['price']?.toStringAsFixed(2)}'),
                                trailing: Text(
                                    '\$${(item['quantity'] * (item['price'] ?? 0)).toStringAsFixed(2)}'),
                              );
                            },
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '\$${orderData['total']?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatusButton(context, orders[index].id,
                                  'processing', orderData['status']),
                              _buildStatusButton(context, orders[index].id,
                                  'shipped', orderData['status']),
                              _buildStatusButton(context, orders[index].id,
                                  'delivered', orderData['status']),
                              _buildStatusButton(context, orders[index].id,
                                  'cancelled', orderData['status']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'processing':
        color = Colors.blue;
        icon = Icons.hourglass_empty;
        break;
      case 'shipped':
        color = Colors.purple;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      avatar: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildStatusButton(BuildContext context, String orderId, String status,
      String currentStatus) {
    return ElevatedButton(
      onPressed: currentStatus.toLowerCase() == status.toLowerCase()
          ? null
          : () {
              _adminService.updateOrderStatus(orderId, status);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: currentStatus.toLowerCase() == status.toLowerCase()
            ? Colors.grey
            : null,
      ),
      child: Text(status.toUpperCase()),
    );
  }
}
