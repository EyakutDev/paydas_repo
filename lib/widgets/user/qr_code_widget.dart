import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../constants/app_colors.dart';

class QRCodeWidget extends StatefulWidget {
  final String data;
  final int expiresInSeconds;
  final VoidCallback? onExpired;

  const QRCodeWidget({
    super.key,
    required this.data,
    this.expiresInSeconds = 300, // 5 dakika varsayılan
    this.onExpired,
  });

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {
  late int _remainingSeconds;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.expiresInSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _isExpired = true;
          widget.onExpired?.call();
        }
      });

      return _remainingSeconds > 0 && mounted;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Kod
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isExpired
              ? _buildExpiredState()
              : QrImageView(
                  data: widget.data,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: AppColors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primaryGreen,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // Süre göstergesi
        if (!_isExpired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _remainingSeconds < 60
                  ? Colors.red.withOpacity(0.1)
                  : AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: _remainingSeconds < 60
                      ? Colors.red
                      : AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kalan süre: ${_formatTime(_remainingSeconds)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _remainingSeconds < 60
                        ? Colors.red
                        : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExpiredState() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_off, size: 48, color: Colors.red.withOpacity(0.6)),
          const SizedBox(height: 12),
          const Text(
            'QR Kod Süresi Doldu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _remainingSeconds = widget.expiresInSeconds;
                _isExpired = false;
              });
              _startCountdown();
            },
            child: const Text('Yenile'),
          ),
        ],
      ),
    );
  }
}
