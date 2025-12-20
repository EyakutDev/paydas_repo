import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String businessId;

  const CodeVerificationScreen({super.key, required this.businessId});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;
  bool? _isValid;
  String? _message;
  Map<String, dynamic>? _reservationData;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kod girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _isValid = null;
      _message = null;
      _reservationData = null;
    });

    try {
      final data = await FirebaseService.verifyReservationCode(
        widget.businessId,
        _codeController.text,
      );

      setState(() {
        _isVerifying = false;
        if (data != null) {
          _isValid = true;
          _reservationData = data;
          _message = 'Kod doğrulandı! Teslim edilebilir.';
          _codeController.clear();
        } else {
          _isValid = false;
          _message = 'Kod geçersiz veya bulunamadı.';
        }
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _isValid = false;
        _message = 'Hata: ${e.toString().replaceAll("Exception: ", "")}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // AppBar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: AppColors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Kod Onaylama',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // İkon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      size: 40,
                      color: AppColors.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Rezervasyon Onayla',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Kullanıcının ilettiği kodu girin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Kod girişi
                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'KODU GİRİN',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        letterSpacing: 0,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Onayla butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppColors.primaryGreen
                            .withOpacity(0.6),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Onayla',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  // Sonuç
                  if (_isValid != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isValid!
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isValid! ? Icons.check_circle : Icons.cancel,
                                color: _isValid! ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _message ?? '',
                                  style: TextStyle(
                                    color: _isValid!
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_isValid! && _reservationData != null) ...[
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Ürün:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(_reservationData!['itemName'] ?? ''),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
