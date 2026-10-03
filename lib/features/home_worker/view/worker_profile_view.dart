import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/core/utils/ui_utils.dart';
import 'package:salhly/features/home/view/about_contact_view.dart';
import 'package:salhly/features/home/view/privacy_policy_view.dart';
import 'package:salhly/features/home_worker/controller/home_worker_controller.dart';
import 'package:salhly/features/user/view/update_password.dart';
import 'package:salhly/features/user/view/update_user.dart';

class WorkerProfileView extends StatelessWidget {
  final bool showAppBar;
  const WorkerProfileView({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: showAppBar
          ? AppBar(
              title: Text(
                'الملف الشخصي',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.blue,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: GetBuilder<HomeWorkerController>(
        builder: (ctrl) {
          final user = ctrl.user;
          final image = user?.image;
          final hasImage = image != null && image.isNotEmpty;
          final imageUrl = hasImage
              ? (image.contains('http')
                  ? image
                  : (image.contains('storage')
                      ? 'https://www.salhly.lareenmedco.com/$image'
                      : 'https://www.salhly.lareenmedco.com/storage/$image'))
              : '';

          return RefreshIndicator(
            color: Colors.blue,
            onRefresh: () async {
              await ctrl.refreshAllOrders();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(user, hasImage, imageUrl),

                  // Stats row
                  _buildStatsSection(ctrl),

                  const SizedBox(height: 16),

                  // Actions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إعدادات الحساب',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildMenuCard([
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            iconColor: Colors.blue,
                            title: 'تعديل الملف الشخصي',
                            subtitle: 'تعديل الاسم ورقم الهاتف والصورة',
                            onTap: () async {
                              await Get.to(() => UpdateUser(userData: user));
                              ctrl.getUser();
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.lock_outline_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'تعديل كلمة المرور',
                            subtitle: 'تغيير كلمة المرور الخاصة بحسابك',
                            onTap: () => Get.to(() => UpdatePassword()),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        Text(
                          'الدعم والمعلومات',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildMenuCard([
                          _buildMenuItem(
                            icon: Icons.feedback_outlined,
                            iconColor: const Color(0xFFEF4444),
                            title: 'الشكاوى والمقترحات',
                            subtitle: 'إرسال ملاحظة أو شكوى لإدارة التطبيق',
                            onTap: () => showComplaintBottomSheet(
                              contextTitle: 'شكاوى ومقترحات الفنيين',
                            ),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFF0EA5E9),
                            title: 'عن التطبيق ومعلومات التواصل',
                            subtitle: 'معلومات عن صلحلي وطرق التواصل',
                            onTap: () => Get.to(() => const AboutContactView()),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: const Color(0xFF10B981),
                            title: 'سياسة الخصوصية',
                            subtitle: 'الشروط وسياسة الاستخدام',
                            onTap: () => Get.to(() => PrivacyPolicyView()),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // Logout button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFEE2E2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                showConfirmDialog(
                                  title: 'تسجيل خروج',
                                  middleText: 'هل أنت متأكد من تسجيل الخروج من حساب الفني؟',
                                  onConfirm: () => ctrl.logout(),
                                  onCancel: () {},
                                  confirmText: 'تسجيل خروج',
                                  cancelText: 'إلغاء',
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        'تسجيل الخروج',
                                        style: GoogleFonts.cairo(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Color(0xFFF87171),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Version
                        Center(
                          child: Text(
                            'تطبيق صلحلي للفنيين • الإصدار 1.0.0',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, bool hasImage, String imageUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, showAppBar ? 28 : 58, 20, 28),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  backgroundImage: hasImage
                      ? CachedNetworkImageProvider(imageUrl)
                      : null,
                  child: !hasImage
                      ? const Icon(
                          Icons.engineering_rounded,
                          size: 46,
                          color: Colors.blue,
                        )
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'فني الصيانة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (user?.phone != null && user!.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_iphone_rounded,
                  size: 15,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  user.phone,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.amberAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'حساب فني معتمد',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(HomeWorkerController ctrl) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'الإجمالي',
                count: ctrl.totalCount,
                color: Colors.blue,
                icon: Icons.assignment_rounded,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                label: 'قيد الانتظار',
                count: ctrl.pendingCount,
                color: const Color(0xFFD97706),
                icon: Icons.hourglass_top_rounded,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                label: 'موافق عليها',
                count: ctrl.approvedCount,
                color: const Color(0xFF2563EB),
                icon: Icons.build_circle_rounded,
              ),
              _buildVerticalDivider(),
              _buildStatItem(
                label: 'المكتملة',
                count: ctrl.completedCount,
                color: const Color(0xFF16A34A),
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9));
  }
}
