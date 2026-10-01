import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:salhly/configs/app_colors.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/service_model.dart';

class ReorderServicesView extends StatefulWidget {
  const ReorderServicesView({super.key});

  @override
  State<ReorderServicesView> createState() => _ReorderServicesViewState();
}

class _ReorderServicesViewState extends State<ReorderServicesView> {
  final HomeController _homeCtrl = Get.find<HomeController>();
  late List<ServicesModel> _reorderedList;
  late List<int> _initialIds;
  bool _hasChanges = false;

  List<ServicesModel> _getRegularServices() {
    final goldenIds = _homeCtrl.goldenServices.map((g) => g.id).toSet();
    return _homeCtrl.services.where((s) => !goldenIds.contains(s.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    _reorderedList = _getRegularServices();
    _initialIds = _reorderedList.map((s) => s.id).toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ServicesModel item = _reorderedList.removeAt(oldIndex);
      _reorderedList.insert(newIndex, item);

      final currentIds = _reorderedList.map((s) => s.id).toList();
      _hasChanges = !_areListsEqual(currentIds, _initialIds);
    });
  }

  bool _areListsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _resetOrder() {
    HapticFeedback.mediumImpact();
    setState(() {
      _reorderedList = _getRegularServices();
      _hasChanges = false;
    });
  }

  Future<void> _saveOrder() async {
    HapticFeedback.heavyImpact();
    final List<int> serviceIds = _reorderedList.map((s) => s.id).toList();
    final bool success = await _homeCtrl.reorderServices(serviceIds);
    if (success && mounted) {
      setState(() {
        _initialIds = List<int>.from(serviceIds);
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.four,
                AppColors.four.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
        title: Text(
          'ترتيب الخدمات',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _resetOrder,
              icon: const Icon(Icons.restore_rounded, color: Colors.white, size: 18),
              label: Text(
                'استعادة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Informative Instruction Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0284C7).withValues(alpha: 0.08),
                  const Color(0xFF38BDF8).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.drag_indicator_rounded,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اضغط باستمرار على أيقونة السحب لتحريك الخدمة للأعلى أو للأسفل لتغيير موقعها، ثم اضغط على حفظ الترتيب.',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Total Services Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قائمة الخدمات الحالية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_reorderedList.length} خدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drag-and-Drop Reorderable List
          Expanded(
            child: _reorderedList.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد خدمات متاحة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _reorderedList.length,
                      onReorder: _onReorder,
                      itemBuilder: (context, index) {
                        final service = _reorderedList[index];
                        final isFirst = index == 0;
                        final isTopThree = index < 3;

                        return Container(
                          key: ValueKey<int>(service.id),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isTopThree
                                  ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                                  : Colors.grey.shade200,
                              width: isTopThree ? 1.4 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                // Rank Indicator Pill
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: isTopThree
                                        ? const LinearGradient(
                                            colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                                          )
                                        : null,
                                    color: isTopThree
                                        ? null
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.cairo(
                                      color: isTopThree
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Service Image Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: service.image,
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: 46,
                                        height: 46,
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 46,
                                      height: 46,
                                      color: const Color(0xFFE2E8F0),
                                      child: const Icon(
                                        Icons.build_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // Service Name & ID
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.title,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'ID: ${service.id}',
                                              style: GoogleFonts.cairo(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                          if (isFirst) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDCFCE7),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'الخدمة الأولى',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF16A34A),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Drag Handle Icon
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.drag_handle_rounded,
                                      color: Color(0xFF64748B),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      // Bottom Floating Action Save Bar
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: GetBuilder<HomeController>(
            builder: (ctrl) {
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: ctrl.isReordering || !_hasChanges
                      ? null
                      : _saveOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: _hasChanges ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: ctrl.isReordering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _hasChanges
                                  ? 'حفظ الترتيب الجديد'
                                  : 'اسحب لتغيير الترتيب',
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _hasChanges
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
