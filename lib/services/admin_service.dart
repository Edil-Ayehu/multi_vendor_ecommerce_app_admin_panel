import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all users (customers and vendors)
  Stream<QuerySnapshot> getAllUsers() {
    try {
      return _firestore
          .collection('users')
          .where('role', isNotEqualTo: 'admin')
          .snapshots();
    } catch (e) {
      print('Error getting users: $e');
      return Stream.empty();
    }
  }

  // Fetch vendors only
  Stream<QuerySnapshot> getVendors() {
    try {
      print('Fetching vendors...'); // Debug print
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'vendor') // Changed from isVendor
          .snapshots();
    } catch (e) {
      print('Error getting vendors: $e');
      return Stream.empty();
    }
  }

  // Fetch customers only
  Stream<QuerySnapshot> getCustomers() {
    try {
      print('Fetching customers...'); // Debug print
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'customer') // Changed from isVendor
          .snapshots();
    } catch (e) {
      print('Error getting customers: $e');
      return Stream.empty();
    }
  }

  // Fetch all products
  Stream<QuerySnapshot> getAllProducts() {
    return _firestore.collection('products').snapshots();
  }

  // Fetch all orders
  Stream<QuerySnapshot> getAllOrders() {
    try {
      return _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting orders: $e');
      return Stream.empty();
    }
  }

  // Fetch all advertisements
  Stream<QuerySnapshot> getAllAds() {
    return _firestore
        .collection('advertisements')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get platform analytics
  Future<Map<String, dynamic>> getPlatformAnalytics() async {
    try {
      print('Fetching platform analytics...'); // Debug print

      final usersCount = await _firestore.collection('users').count().get();
      print('Users count: ${usersCount.count}'); // Debug print

      final productsCount =
          await _firestore.collection('products').count().get();
      print('Products count: ${productsCount.count}'); // Debug print

      final ordersCount = await _firestore.collection('orders').count().get();
      print('Orders count: ${ordersCount.count}'); // Debug print

      // Get all orders and calculate total revenue
      final QuerySnapshot ordersSnapshot =
          await _firestore.collection('orders').get();
      double totalRevenue = 0;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Make sure to use the correct field name that contains the order total
        final amount = data['totalAmount'] ?? data['total'] ?? 0;
        totalRevenue += (amount is num) ? amount.toDouble() : 0.0;
      }

      print('Total revenue: $totalRevenue'); // Debug print

      return {
        'totalUsers': usersCount.count,
        'totalProducts': productsCount.count,
        'totalOrders': ordersCount.count,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('Error fetching analytics: $e'); // Debug print
      return {
        'totalUsers': 0,
        'totalProducts': 0,
        'totalOrders': 0,
        'totalRevenue': 0.0,
      };
    }
  }

  // Block/Unblock user
  Future<void> toggleUserStatus(String userId, bool isBlocked) async {
    await _firestore.collection('users').doc(userId).update({
      'isBlocked': isBlocked,
    });
  }

  // Remove product
  Future<void> removeProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Remove advertisement
  Future<void> removeAd(String adId) async {
    await _firestore.collection('advertisements').doc(adId).delete();
  }

  // Remove product review
  Future<void> removeProductReview(String productId, String reviewId) async {
    try {
      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) return;

      final reviews =
          List<Map<String, dynamic>>.from(productDoc.data()?['reviews'] ?? []);
      reviews.removeWhere((review) => review['id'] == reviewId);

      // Recalculate average rating
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += (review['rating'] as num).toDouble();
      }
      final averageRating =
          reviews.isEmpty ? 0.0 : totalRating / reviews.length;

      await _firestore.collection('products').doc(productId).update({
        'reviews': reviews,
        'averageRating': averageRating,
        'totalReviews': reviews.length,
      });
    } catch (e) {
      print('Error removing review: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // Add advertisement
  // Get all advertisements
  Stream<QuerySnapshot> getAllAdvertisements() {
    try {
      return _firestore
          .collection('advertisements')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting advertisements: $e');
      return Stream.empty();
    }
  }

  // Toggle advertisement status
  Future<void> toggleAdvertisementStatus(String adId, bool isActive) async {
    try {
      await _firestore.collection('advertisements').doc(adId).update({
        'isActive': isActive,
      });
    } catch (e) {
      print('Error toggling advertisement status: $e');
    }
  }

  // Remove advertisement
  Future<void> removeAdvertisement(String adId) async {
    try {
      await _firestore.collection('advertisements').doc(adId).delete();
    } catch (e) {
      print('Error removing advertisement: $e');
    }
  }

  //
  Future<List<Map<String, dynamic>>> getRevenueData() async {
    try {
      final QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: false)
          .get();

      Map<String, double> monthlyRevenue = {};

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final DateTime date = (data['createdAt'] as Timestamp).toDate();
        final String monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        final double amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

        monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + amount;
      }

      return monthlyRevenue.entries
          .map((e) => {
                'date': e.key,
                'amount': e.value,
              })
          .toList();
    } catch (e) {
      print('Error getting revenue data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserGrowthData() async {
    try {
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: false)
          .get();

      // Create a map to store monthly user counts
      Map<String, int> monthlyUsers = {};

      // Get current date for last 6 months data
      DateTime now = DateTime.now();
      for (int i = 5; i >= 0; i--) {
        DateTime month = DateTime(now.year, now.month - i, 1);
        String monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
        monthlyUsers[monthKey] = 0;
      }

      // Count users per month
      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] != null) {
          final DateTime date = (data['createdAt'] as Timestamp).toDate();
          final String monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          if (monthlyUsers.containsKey(monthKey)) {
            monthlyUsers[monthKey] = (monthlyUsers[monthKey] ?? 0) + 1;
          }
        }
      }

      // Convert to list of maps and sort by date
      List<Map<String, dynamic>> result = monthlyUsers.entries.map((entry) {
        return {
          'date': entry.key,
          'count': entry.value,
        };
      }).toList();

      result.sort((a, b) => a['date'].compareTo(b['date']));
      
      print('User growth data: $result'); // Debug print
      return result;
    } catch (e) {
      print('Error getting user growth data: $e');
      return [];
    }
  }

  Future<Map<String, int>> getOrderStatusDistribution() async {
    try {
      final QuerySnapshot ordersSnapshot =
          await _firestore.collection('orders').get();

      Map<String, int> statusCount = {
        'pending': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = (data['status'] as String?)?.toLowerCase() ?? 'pending';
        if (statusCount.containsKey(status)) {
          statusCount[status] = (statusCount[status] ?? 0) + 1;
        }
      }

      return statusCount;
    } catch (e) {
      print('Error getting order status distribution: $e');
      return {
        'pending': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };
    }
  }
}
