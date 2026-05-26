import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/features/maintenance/controller/maintenance_order_detail_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceOrderDetailView extends StatefulWidget {
  final int orderId;
  const MaintenanceOrderDetailView({super.key, required this.orderId});

  @override
  State<MaintenanceOrderDetailView> createState() => _MaintenanceOrderDetailViewState();
}

class _MaintenanceOrderDetailViewState extends State<MaintenanceOrderDetailView>
    with TickerProviderStateMixin {
  late MaintenanceOrderDetailController controller;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MaintenanceOrderDetailController());
    controller.fetchMaintenanceOrder(widget.orderId);
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm', 'en').format(date.toLocal());
    } catch (e) {
      return dateString;
    }
  }

  String getStatusLabel(String status) {
    final statusMap = {
      'pending': 'قيد الانتظار',
      'in_progress': 'قيد التنفيذ',
      'completed': 'مكتمل',
      'cancelled': 'ملغى',
    };
    return statusMap[status] ?? status;
  }

  Color getStatusColor(String status) {
    final colorMap = {
      'pending': Color(0xFFFF9800),
      'in_progress': Colors.blue,
      'completed': Color(0xFF4CAF50),
      'cancelled': Color(0xFFF44336),
    };
    return colorMap[status] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<MaintenanceOrderDetailController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.four),
            );
          }

          if (ctrl.order == null) {
            return Center(
              child: Text(
                'لم يتم العثور على الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          final order = ctrl.order!;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Header Hero Section
                  SliverAppBar(
                    elevation: 0,
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: AppColors.four,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeroHeader(order),
                      collapseMode: CollapseMode.parallax,
                    ),
                  ),

                  // Content sections
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: 20),

                        // Quick Info Pills
                        _buildQuickInfo(formatDate),
                        SizedBox(height: 24),

                        // Service Details Card
                        _buildServiceCard(order),
                        SizedBox(height: 24),

                        // Details Cards Grid
                        _buildDetailsGrid(formatDate),
                        SizedBox(height: 24),

                        // Additional Info
                        _buildAdditionalInfo(order, formatDate),
                        SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader(order) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.four, Color(0xFF0D3B66)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _BackgroundPatternPainter()),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      "",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Main Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.fullName,
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.address,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(
    String Function(String) formatDate,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickInfoPill(
            icon: Icons.phone,
            label: 'الهاتف',
            value: controller.order?.phoneNumber ?? '',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _QuickInfoPill(
            icon: Icons.calendar_today,
            label: 'التاريخ',
            value: controller.order != null ? formatDate(controller.order!.createdAt) : '-',
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(order) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.four.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.four.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.four.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: AppColors.four,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الخدمة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.service.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.four.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.category, color: AppColors.four, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النوع الفرعي',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.subService.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 14),
          Text(
            'الوصف',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            order.description,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(String Function(String) formatDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل الطلب',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DetailCard(
                icon: Icons.phone,
                title: 'الهاتف',
                value: controller.order?.phoneNumber ?? '',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _DetailCard(
                icon: Icons.calendar_today,
                title: 'التاريخ',
                value: controller.order != null ? formatDate(controller.order!.createdAt) : '-',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(
    order,
    String Function(String) formatDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات إضافية',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoItem('الحالة الحالية', getStatusLabel(order.status)),
              SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 1),
              SizedBox(height: 12),
              _InfoItem(
                'تاريخ الإنشاء',
                formatDate(order.createdAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _InfoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _QuickInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickInfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.four.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.four.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.four),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.four),
              SizedBox(width: 8),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw diagonal lines pattern
    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(i * 40.0, 0),
        Offset(i * 40.0 + size.height, size.height),
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

