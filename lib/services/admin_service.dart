import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all users (customers and vendors)
  Stream<QuerySnapshot> getAllUsers() {
    try {
      return _firestore.collection('users').snapshots();
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
      
      final productsCount = await _firestore.collection('products').count().get();
      print('Products count: ${productsCount.count}'); // Debug print
      
      final ordersCount = await _firestore.collection('orders').count().get();
      print('Orders count: ${ordersCount.count}'); // Debug print
      
      final orders = await _firestore.collection('orders').get();
      double totalRevenue = 0;
      for (var order in orders.docs) {
        totalRevenue += (order.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
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
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) return;

      final reviews = List<Map<String, dynamic>>.from(productDoc.data()?['reviews'] ?? []);
      reviews.removeWhere((review) => review['id'] == reviewId);

      // Recalculate average rating
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += (review['rating'] as num).toDouble();
      }
      final averageRating = reviews.isEmpty ? 0.0 : totalRating / reviews.length;

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
}