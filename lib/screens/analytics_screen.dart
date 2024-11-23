import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Analytics',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _adminService.getPlatformAnalytics(),
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
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
            );
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSummaryCards(data, context),
                const SizedBox(height: 30),
                _buildSectionTitle('Revenue Trend'),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildRevenueChart(),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('User Growth'),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildUserGrowthChart(),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Order Distribution'),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildOrderStatusChart(),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Advertisement Analytics'),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildAdvertisementChart(),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Product Category Analytics'),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildProductCategoryChart(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data, BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildStatCard(
          'Total Users',
          data['totalUsers'].toString(),
          Icons.people_alt_rounded,
          const Color(0xFF6366F1), // Indigo
          context,
        ),
        _buildStatCard(
          'Total Products',
          data['totalProducts'].toString(),
          Icons.inventory_2_rounded,
          const Color(0xFF0EA5E9), // Sky blue
          context,
        ),
        _buildStatCard(
          'Total Orders',
          data['totalOrders'].toString(),
          Icons.shopping_bag_rounded,
          const Color(0xFF10B981), // Emerald
          context,
        ),
        _buildStatCard(
          'Revenue',
          '\$${NumberFormat('#,##0.00').format(data['totalRevenue'])}',
          Icons.attach_money_rounded,
          const Color(0xFFF59E0B), // Amber
          context,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background Icon
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 80,
              color: color.withOpacity(0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Value
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminService.getRevenueData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text('No revenue data available'));
        }

        // Sort data by date
        data.sort((a, b) => a['date'].compareTo(b['date']));

        // Create spots for the line chart
        final spots = data.asMap().entries.map((entry) {
          return FlSpot(
            entry.key.toDouble(),
            entry.value['amount'].toDouble(),
          );
        }).toList();

        // Find min and max values for better scaling
        final maxY = data.fold<double>(
            0, (max, item) => math.max(max, item['amount'].toDouble()));

        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revenue Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last ${data.length} months',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 0 ? maxY / 5 : 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < data.length) {
                              final date =
                                  data[value.toInt()]['date'] as String;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  date.substring(
                                      5), // Show only month part (MM)
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxY > 0 ? maxY / 5 : 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '\$${value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (data.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY * 1.1, // Add 10% padding at the top
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.purple,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.purple.withOpacity(0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        // tooltipBackground: Colors.blueAccent,

                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final index = barSpot.x.toInt();
                            final date = data[index]['date'] as String;
                            final amount = data[index]['amount'].toDouble();
                            return LineTooltipItem(
                              '$date\n\$${amount.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserGrowthChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminService.getUserGrowthData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text('No user growth data available'));
        }

        // Calculate max value for scaling
        final maxCount = data.fold<int>(
          0,
          (max, item) => math.max(max, item['count'] as int),
        );

        // Create bar groups
        final barGroups = data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value['count'].toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList();

        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Growth',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last ${data.length} months',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxCount > 5 ? maxCount / 5 : 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < data.length) {
                              final date =
                                  data[value.toInt()]['date'] as String;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  date.substring(
                                      5), // Show only month part (MM)
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxCount > 5 ? maxCount / 5 : 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${data[group.x]['count']} users',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusChart() {
    return FutureBuilder<Map<String, int>>(
      future: _adminService.getOrderStatusDistribution(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final total = data.values.fold<int>(0, (sum, value) => sum + value);

        if (total == 0) {
          return const Center(child: Text('No order status data available'));
        }

        return Container(
          height: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                        'Order Status',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total Orders: $total',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Real-time',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: [
                            _buildOrderSection(
                                'Pending', data, total, Colors.orange),
                            _buildOrderSection(
                                'Shipped', data, total, Colors.blue),
                            _buildOrderSection(
                                'Delivered', data, total, Colors.green),
                            _buildOrderSection(
                                'Cancelled', data, total, Colors.red),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildOrderLegendItem('Pending', data['pending'] ?? 0,
                              total, Colors.orange),
                          const SizedBox(height: 16),
                          _buildOrderLegendItem('Shipped', data['shipped'] ?? 0,
                              total, Colors.blue),
                          const SizedBox(height: 16),
                          _buildOrderLegendItem('Delivered',
                              data['delivered'] ?? 0, total, Colors.green),
                          const SizedBox(height: 16),
                          _buildOrderLegendItem('Cancelled',
                              data['cancelled'] ?? 0, total, Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PieChartSectionData _buildOrderSection(
      String status, Map<String, int> data, int total, Color color) {
    final value = (data[status.toLowerCase()] ?? 0).toDouble();
    final percentage = total > 0 ? (value / total * 100) : 0;

    return PieChartSectionData(
      color: color.withOpacity(0.8),
      value: value,
      title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
      radius: 60,
      titleStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      badgeWidget: percentage < 5 ? null : _buildBadge(color),
      badgePositionPercentageOffset: 1.2,
    );
  }

  Widget _buildBadge(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  Widget _buildOrderLegendItem(
      String status, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count orders (${percentage.toStringAsFixed(1)}%)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvertisementChart() {
    return FutureBuilder<Map<String, int>>(
      future: _adminService.getAdvertisementDistribution(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final total = data['total'] ?? 0;

        if (total == 0) {
          return const Center(child: Text('No advertisement data available'));
        }

        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advertisement Distribution',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: (data['active'] ?? 0).toDouble(),
                              title:
                                  '${((data['active'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                              radius: 50,
                              titleStyle: const TextStyle(color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.red,
                              value: (data['expired'] ?? 0).toDouble(),
                              title:
                                  '${((data['expired'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                              radius: 50,
                              titleStyle: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAdLegendItem(
                              'Active', Colors.green, data['active'] ?? 0),
                          const SizedBox(height: 8),
                          _buildAdLegendItem(
                              'Expired', Colors.red, data['expired'] ?? 0),
                          const SizedBox(height: 16),
                          Text(
                            'Total Ads: ${data['total']}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCategoryChart() {
    return FutureBuilder<Map<String, int>>(
      future: _adminService.getProductCategoryDistribution(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final sortedData = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Categories Distribution',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: sortedData.first.value.toDouble() * 1.2,
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(fontSize: 12),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 100,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= sortedData.length)
                              return const Text('');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: SizedBox(
                                  width: 80,
                                  child: Text(
                                    sortedData[value.toInt()].key,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: sortedData.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.value.toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildAdLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }
}
