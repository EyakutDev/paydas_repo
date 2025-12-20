import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/business_register_form.dart';
import '../widgets/user_register_form.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Container(
          height: 110,
          width: 110,
          padding: const EdgeInsets.all(12), // Beyaz çember içi boşluk
          decoration: const BoxDecoration(
            color: AppColors.white, // Beyaz arka plan
            shape: BoxShape.circle, // Yuvarlak
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

          // ===============================
          // TAB BAR
          // ===============================
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
                ],
              ),
            ),
          ),

          // ===============================
          // TAB VIEW
          // ===============================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [BusinessRegisterForm(), UserRegisterForm()],
            ),
          ),

          // ===============================
          // GİRİŞ YAP
          // ===============================
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabın var mı? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Giriş Yap',
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
