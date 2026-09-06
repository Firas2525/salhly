import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salhly/configs/app_colors.dart';
import 'package:salhly/core/utils/ui_utils.dart';
import 'package:salhly/features/home/controller/home_controller.dart';
import 'package:salhly/features/home/exchange_requests/exchange_requests_view.dart';
import 'package:salhly/features/home/sell_requests/sell_requests_view.dart';
import 'package:salhly/features/requests/view/requests_view.dart';
import 'package:salhly/features/user/view/update_password.dart';
import 'package:salhly/features/user/view/update_user.dart';

import '../view/privacy_policy_view.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: GetBuilder<HomeController>(
          builder: (homeCtrl) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(homeCtrl),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        children: [
                          _buildTile(
                            icon: Icons.lock_outline,
                            title: 'تعديل كلمة المرور',
                            onTap: () => Get.to(() => UpdatePassword()),
                          ),
                          _buildTile(
                            icon: Icons.list_alt_rounded,
                            title: 'الطلبات',
                            onTap: () => Get.to(() => RequestsView()),
                          ),
                          _buildTile(
                            icon: Icons.sell,
                            title: 'طلبات البيع',
                            onTap: () => Get.to(() => SellRequestsView()),
                          ),
                          _buildTile(
                            icon: Icons.swap_horiz,
                            title: 'طلبات الاستبدال',
                            onTap: () => Get.to(() => ExchangeRequestsView()),
                          ),
                          _buildTile(
                            icon: Icons.person_outline,
                            title: 'تعديل الحساب',
                            onTap: () => Get.to(
                              () => UpdateUser(userData: homeCtrl.user),
                            ),
                          ),
                          _buildTile(
                            icon: Icons.privacy_tip,
                            title: 'سياسة الخصوصية',
                            onTap: () => Get.to(() => PrivacyPolicyView()),
                          ),
                          const Divider(),
                          _buildTile(
                            icon: Icons.delete_outline,
                            title: 'حذف الحساب',
                            color: Colors.redAccent,
                            onTap: () {
                              showConfirmDialog(
                                title: 'حذف الحساب',
                                middleText: 'هل انت متأكد انك تريد حذف الحساب',
                                onConfirm: homeCtrl.deleteAccount,
                                onCancel: () {},
                                confirmText: 'نعم',
                                cancelText: 'لا',
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                showConfirmDialog(
                                  title: 'تسجيل خروج',
                                  middleText:
                                      'هل انت متأكد تسجيل خروجك من الحساب',
                                  onConfirm: homeCtrl.logout,
                                  onCancel: () {},
                                  confirmText: 'نعم',
                                  cancelText: 'لا',
                                );
                              },
                              icon: const Icon(
                                Icons.logout_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                'تسجيل خروج',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              'نسخة التطبيق 1.0.0',
                              style: GoogleFonts.cairo(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(HomeController homeCtrl) {
    final image = homeCtrl.user?.image;
    final hasImage = image != null && image.isNotEmpty;
    final imageUrl = hasImage
        ? 'https://www.salhly.lareenmedco.com/$image'
        : '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hasImage
              ? CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(
                    imageUrl.contains('storage')
                        ? imageUrl
                        : 'https://www.salhly.lareenmedco.com/storage/$image',
                  ),
                )
              : Container(
                  height: 68,
                  width: 68,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/logo2.png',
                    fit: BoxFit.contain,
                  ),
                ),
          const SizedBox(height: 12),
          Text(
            homeCtrl.user?.name ?? 'اسم المستخدم',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            homeCtrl.user?.phone ?? '',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF4682A9),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
