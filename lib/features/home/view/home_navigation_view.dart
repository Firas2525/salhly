import 'package:flutter/material.dart';

import '../../requests/view/requests_view.dart';
import '../../user/view/update_user.dart';
import 'all_offers_view.dart';
import 'home_page_view.dart';
import 'sell_exchange_home_view.dart';

class HomeNavigationView extends StatefulWidget {
  const HomeNavigationView({super.key});

  @override
  State<HomeNavigationView> createState() => _HomeNavigationViewState();
}

class _HomeNavigationViewState extends State<HomeNavigationView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePageView(),
    SellExchangeHomeView(),
    AllOffersView(title: 'العروض', useExchangeOffers: false),
    RequestsView(),
    UpdateUser(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: Container(
          height: 76,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFE3EEF4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4682A9).withOpacity(0.16),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildDestination(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'الرئيسية',
              ),
              _buildDestination(
                index: 1,
                icon: Icons.swap_horiz_outlined,
                selectedIcon: Icons.swap_horiz_rounded,
                label: 'بيع واستبدال',
              ),
              _buildDestination(
                index: 2,
                icon: Icons.local_offer_outlined,
                selectedIcon: Icons.local_offer_rounded,
                label: 'العروض',
              ),
              _buildDestination(
                index: 3,
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                label: 'الطلبات',
              ),
              _buildDestination(
                index: 4,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestination({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _onItemTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEAF4F8)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: isSelected ? 30 : 27,
                  height: isSelected ? 27 : 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4682A9)
                        : const Color(0xFFF1F5F7),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      key: ValueKey('$index-$isSelected'),
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF78909C),
                      size: isSelected ? 17 : 16,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF4682A9)
                        : const Color(0xFF607D8B),
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: isSelected ? 18 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2A23A),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
