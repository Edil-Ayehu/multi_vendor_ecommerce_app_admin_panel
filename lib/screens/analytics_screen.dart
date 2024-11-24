import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:multi_vendor_ecommerce_app_admin_panel/services/admin_service.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

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
                _buildSectionTitle('Product Category Analytics'),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildProductCategoryChart(),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('Advertisement Analytics'),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildAdvertisementChart(),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
          return _buildShimmerContainer(
            height: 400,
            baseColor: const Color(0xff203857).withOpacity(0.5),
            highlightColor: const Color(0xff203857).withOpacity(0.3),
          );
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text('No revenue data available'));
        }

        // Format revenue values using NumberFormat
        final numberFormat = NumberFormat('#,##0.00');

        data.sort((a, b) => a['date'].compareTo(b['date']));
        final spots = data.asMap().entries.map((entry) {
          final amount = entry.value['amount'] as double;
          return FlSpot(
            entry.key.toDouble(),
            amount,
          );
        }).toList();

        final maxY = math.max(
          data.fold<double>(
              0, (max, item) => math.max(max, item['amount'] as double)),
          1.0,
        );

        return Container(
          height: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF3498DB),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
                        'Revenue Trend',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Last ${data.length} months',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total: \$${numberFormat.format(data.fold<double>(0, (sum, item) => sum + (item['amount'] as double)))}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: math.max(maxY / 5, 1.0),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '\$${numberFormat.format(value)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
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
                                  date.substring(5),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.white,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: const Color(0xFF2C3E50),
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final data = snapshot.data![spot.x.toInt()];
                            return LineTooltipItem(
                              'Revenue: \$${numberFormat.format(data['amount'])}',
                              GoogleFonts.poppins(
                                color: const Color(0xFF2C3E50),
                                fontWeight: FontWeight.w600,
                              ),
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
          return _buildShimmerContainer(
            height: 350,
            baseColor: const Color(0xff203857).withOpacity(0.5),
            highlightColor: const Color(0xff203857).withOpacity(0.3),
          );
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text('No user growth data available'));
        }

        double maxY = 0;
        for (var item in data) {
          maxY = math.max(maxY, (item['customers'] as int).toDouble());
          maxY = math.max(maxY, (item['vendors'] as int).toDouble());
        }

        return Container(
          height: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff203857),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Growth',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Last ${data.length} months',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildUserGrowthLegendItem(
                            'Customers', const Color(0xFF6366F1)),
                        const SizedBox(width: 16),
                        _buildUserGrowthLegendItem(
                            'Vendors', const Color(0xFF10B981)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        // tooltipBgColor: Colors.white.withOpacity(0.9),
                        tooltipRoundedRadius: 8,
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final item = data[group.x.toInt()];
                          final value = rodIndex == 0
                              ? item['customers']
                              : item['vendors'];
                          final type = rodIndex == 0 ? 'Customers' : 'Vendors';
                          return BarTooltipItem(
                            '$type\n$value',
                            GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
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
                                  date.substring(5),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 5 ? maxY / 5 : 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.asMap().entries.map((entry) {
                      final customers = entry.value['customers'] as int;
                      final vendors = entry.value['vendors'] as int;

                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: customers.toDouble(),
                            color: const Color(0xFF6366F1),
                            width: 12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          BarChartRodData(
                            toY: vendors.toDouble(),
                            color: const Color(0xFF10B981),
                            width: 12,
                            borderRadius: BorderRadius.circular(2),
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

  Widget _buildUserGrowthLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
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
          return _buildShimmerContainer(
            height: 500,
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
          );
        }

        final data = snapshot.data!;
        final total = data.values.fold<int>(0, (sum, value) => sum + value);

        if (total == 0) {
          return const Center(child: Text('No order status data available'));
        }

        return Container(
          height: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF3498DB),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
                        'Order Distribution',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total Orders: $total',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.refresh,
                            size: 16, color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Real-time',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: [
                            _buildOrderSection('Pending', data, total,
                                const Color(0xFFFFA726)),
                            _buildOrderSection('Shipped', data, total,
                                const Color(0xFF42A5F5)),
                            _buildOrderSection('Delivered', data, total,
                                const Color(0xFF66BB6A)),
                            _buildOrderSection('Cancelled', data, total,
                                const Color(0xFFEF5350)),
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
                              total, const Color(0xFFFFA726)),
                          const SizedBox(height: 24),
                          _buildOrderLegendItem('Shipped', data['shipped'] ?? 0,
                              total, const Color(0xFF42A5F5)),
                          const SizedBox(height: 24),
                          _buildOrderLegendItem(
                              'Delivered',
                              data['delivered'] ?? 0,
                              total,
                              const Color(0xFF66BB6A)),
                          const SizedBox(height: 24),
                          _buildOrderLegendItem(
                              'Cancelled',
                              data['cancelled'] ?? 0,
                              total,
                              const Color(0xFFEF5350)),
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

  Widget _buildOrderLegendItem(
      String status, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$count orders (${percentage.toStringAsFixed(1)}%)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          return _buildShimmerContainer(
            height: 400,
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
          );
        }

        final data = snapshot.data!;
        final total = data['total'] ?? 0;

        if (total == 0) {
          return const Center(child: Text('No advertisement data available'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isVerySmallHeight = constraints.maxHeight < 400;

            return Container(
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 400 : 300,
                maxHeight: isSmallScreen ? 450 : 400,
              ),
              padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2C3E50), // Dark blue
                    const Color(0xFF3498DB), // Light blue
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Advertisement Status',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 14 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (!isVerySmallHeight) ...[
                              const SizedBox(height: 1),
                              Text(
                                'Total Ads: $total',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 10 : 13,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Real-time',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  Expanded(
                    child: isSmallScreen
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildAdsPieChart(
                                    data, total, isSmallScreen),
                              ),
                              if (!isVerySmallHeight)
                                const SizedBox(height: 24),
                              Expanded(
                                flex: 2,
                                child:
                                    _buildAdsLegend(data, total, isSmallScreen),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildAdsPieChart(
                                    data, total, isSmallScreen),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                flex: 2,
                                child:
                                    _buildAdsLegend(data, total, isSmallScreen),
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
    );
  }

  Widget _buildAdsPieChart(
      Map<String, int> data, int total, bool isSmallScreen) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: isSmallScreen ? 30 : 50,
        sections: [
          _buildAdSection('Active', data['active'] ?? 0, total, Colors.green,
              isSmallScreen),
          _buildAdSection('Expired', data['expired'] ?? 0, total, Colors.red,
              isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildAdsLegend(Map<String, int> data, int total, bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAdvertisementLegendItem(
            'Active', data['active'] ?? 0, total, Colors.green, isSmallScreen),
        SizedBox(height: isSmallScreen ? 8 : 16),
        _buildAdvertisementLegendItem(
            'Expired', data['expired'] ?? 0, total, Colors.red, isSmallScreen),
      ],
    );
  }

  PieChartSectionData _buildAdSection(
      String label, int count, int total, Color color, bool isSmallScreen) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    return PieChartSectionData(
      color: color.withOpacity(0.8),
      value: count.toDouble(),
      title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
      radius: isSmallScreen ? 45 : 60,
      titleStyle: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 12 : 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAdvertisementLegendItem(
      String label, int count, int total, Color color, bool isSmallScreen) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallScreen ? 8 : 12,
            height: isSmallScreen ? 8 : 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$count ads (${percentage.toStringAsFixed(1)}%)',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          return _buildShimmerContainer(
            height: 400,
            baseColor: const Color(0xff203857).withOpacity(0.5),
            highlightColor: const Color(0xff203857).withOpacity(0.3),
          );
        }

        final data = snapshot.data!;
        final sortedData = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Calculate total products
        final totalProducts =
            data.values.fold<int>(0, (sum, value) => sum + value);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;

            return Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff203857),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Categories Distribution',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total Products: $totalProducts',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Real-time',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
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
                                if (value.toInt() >= sortedData.length) {
                                  return const Text('');
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Transform.rotate(
                                    angle: -0.5,
                                    child: SizedBox(
                                      width: 80,
                                      child: Text(
                                        sortedData[value.toInt()].key,
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 10 : 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
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
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.1),
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

  Widget _buildShimmerContainer({
    required double height,
    required Color baseColor,
    required Color highlightColor,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
        ),
      ),
    );
  }

  PieChartSectionData _buildOrderSection(
      String label, Map<String, int> data, int total, Color color) {
    final count = data[label.toLowerCase()] ?? 0;
    final percentage = total > 0 ? (count / total * 100) : 0;

    return PieChartSectionData(
      color: color.withOpacity(0.8),
      value: count.toDouble(),
      title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
      radius: 60,
      titleStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      badgeWidget: percentage >= 5
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      badgePositionPercentageOffset: 1.2,
    );
  }
}
