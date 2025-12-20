/// TR telefon numarası validasyonu
class PhoneValidator {
  /// Format: 05XX XXX XX XX veya +90 5XX XXX XX XX
  static bool isValid(String phone) {
    // Temizle
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // +90 ile başlıyorsa
    if (cleaned.startsWith('+90')) {
      final number = cleaned.substring(3);
      return number.length == 10 && number.startsWith('5');
    }

    // 0 ile başlıyorsa
    if (cleaned.startsWith('0')) {
      final number = cleaned.substring(1);
      return number.length == 10 && number.startsWith('5');
    }

    // Sadece numara
    return cleaned.length == 10 && cleaned.startsWith('5');
  }

  /// Format telefon numarasını +90 formatına çevir
  static String formatToE164(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.startsWith('+90')) {
      return cleaned;
    }

    if (cleaned.startsWith('0')) {
      return '+90${cleaned.substring(1)}';
    }

    return '+90$cleaned';
  }

  /// Görüntüleme formatı: 05XX XXX XX XX
  static String formatForDisplay(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    String number = cleaned;

    if (cleaned.startsWith('90')) {
      number = cleaned.substring(2);
    }

    if (number.length == 10) {
      return '0${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6, 8)} ${number.substring(8)}';
    }

    return phone;
  }

  /// Son 4 hane maskeli
  static String maskPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    String number = cleaned;

    if (cleaned.startsWith('90')) {
      number = cleaned.substring(2);
    }

    if (number.length >= 4) {
      final lastFour = number.substring(number.length - 4);
      return '+90 *** *** ** $lastFour';
    }

    return phone;
  }
}
