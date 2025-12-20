import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';
import '../register_screen.dart';
import '../../models/restaurant.dart';
import 'askidaki_urunler_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'reservation_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 0;
  late TabController _homeTabController;

  @override
  void initState() {
    super.initState();
    _homeTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _homeTabController.dispose();
    super.dispose();
  }

  void _onReserve(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildHomeScreen(),
          const MapScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Ana Sayfa'),
                _buildNavItem(1, Icons.map_outlined, Icons.map, 'Harita'),
                _buildNavItem(2, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _bottomNavIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        // AppBar
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.white),
                  onPressed: () async {
                    await FirebaseService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _homeTabController,
              indicator: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.textSecondary,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(height: 40, text: 'Askıdaki Ürünler'),
                Tab(height: 40, text: 'Askıya Ürün Ekle'),
              ],
            ),
          ),
        ),

        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _homeTabController,
            children: [
              AskidakiUrunlerScreen(onReserve: _onReserve),
              const AskiyaEkleScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
