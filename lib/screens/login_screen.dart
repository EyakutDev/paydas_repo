import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/business_login_form.dart';
import '../widgets/user_login_form.dart';
import '../widgets/muhtar_login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        toolbarHeight: 150, // Daha küçük bar
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ), // Geri butonu beyaz olsun
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Container(
          height: 110,
          width: 110,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),

          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(height: 40, text: 'İşletme'),
                  Tab(height: 40, text: 'Kullanıcı'),
                  Tab(height: 40, text: 'Muhtar'),
                ],
              ),
            ),
          ),

          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BusinessLoginForm(),
                UserLoginForm(),
                MuhtarLoginForm(),
              ],
            ),
          ),

          // Kayıt Ol Linki
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabın yok mu? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
