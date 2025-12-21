import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Oturum süresince ID'yi tutmak için (Remember Me kapalı olsa bile)
  static String? currentUserId;

  // Collections
  static CollectionReference get users => _firestore.collection('users');
  static CollectionReference get businesses =>
      _firestore.collection('businesses');
  static CollectionReference get reservations =>
      _firestore.collection('reservations');
  static CollectionReference get donations =>
      _firestore.collection('donations');
  static CollectionReference get applications =>
      _firestore.collection('applications');

  // ==================== AUTH ====================

  /// E-posta ile giriş yap
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    // Dil ayarını Türkçe yap
    await _auth.setLanguageCode('tr');

    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Doğrulama mailini tekrar gönder
  static Future<void> resendVerificationEmail(
    String email,
    String password,
  ) async {
    await _auth.setLanguageCode('tr');

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!credential.user!.emailVerified) {
      await credential.user!.sendEmailVerification();
    }

    await _auth.signOut();
  }

  /// Çıkış yap
  static Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
    await prefs.remove('userId');
  }

  /// Mevcut kullanıcı
  static User? get currentUser => _auth.currentUser;

  // ==================== REMEMBER ME ====================

  static Future<void> saveRememberMe({
    required String userType,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
    await prefs.setString('userId', userId);
    await prefs.setBool('rememberMe', true);
  }

  static Future<Map<String, String>?> getRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (!rememberMe) return null;

    final userType = prefs.getString('userType');
    final userId = prefs.getString('userId');
    if (userType != null && userId != null) {
      if (_auth.currentUser != null) {
        return {'userType': userType, 'userId': userId};
      }
    }
    return null;
  }

  // ==================== USER ====================

  /// Kullanıcı kaydet (Auth + Firestore)
  static Future<String> registerUser({
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
    required String district,
  }) async {
    // 0. Telefon & Email Uniqueness Kontrolü
    // Kullanıcılarda ara
    final existingUser = await getUserByPhone(phone);
    if (existingUser != null) {
      throw Exception(
        'Bu telefon numarası başka bir kullanıcı tarafından kullanılıyor.',
      );
    }

    // İşletmelerde ara
    final existingBusiness = await getBusinessByPhone(phone);
    if (existingBusiness != null) {
      throw Exception(
        'Bu telefon numarası bir işletme hesabı tarafından kullanılıyor.',
      );
    }

    await _auth.setLanguageCode('tr');

    // 1. Auth kaydı
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user!;
    final uid = user.uid;

    // 2. Doğrulama maili gönder
    await user.sendEmailVerification();

    // 3. Firestore kaydı
    await users.doc(uid).set({
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'district': district,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'user',
    });

    // Doğrulanmadığı için oturumu kapat
    await _auth.signOut();

    return uid;
  }

  /// Kullanıcı bul (telefon ile - opsiyonel kontrol için)
  /// Hem +90'lı (E164) hem de 0 ile başlayan (Display) formatları kontrol eder
  static Future<DocumentSnapshot?> getUserByPhone(String phone) async {
    // 1. Gelen numarayı temizle (sadece rakamlar)
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    String rawNumber = cleaned;

    // Eğer 90 ile başlıyorsa (ülke kodu), onu at ve 10 haneli hale getir
    if (cleaned.startsWith('90') && cleaned.length > 10) {
      rawNumber = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length > 10) {
      // 0 ile başlıyorsa at
      rawNumber = cleaned.substring(1);
    }

    // Elimizde "5XXXXXXXXX" gibi 10 haneli ham numara var.
    // Veritabanında şu formatlar olabilir:
    // 1. +905XXXXXXXXX (PhoneValidator.formatToE164)
    // 2. 05XXXXXXXXX
    // 3. 5XXXXXXXXX

    final candidate1 = '+90$rawNumber';
    final candidate2 = '0$rawNumber';
    final candidate3 = rawNumber;

    final query1 = await users
        .where('phone', isEqualTo: candidate1)
        .limit(1)
        .get();
    if (query1.docs.isNotEmpty) return query1.docs.first;

    final query2 = await users
        .where('phone', isEqualTo: candidate2)
        .limit(1)
        .get();
    if (query2.docs.isNotEmpty) return query2.docs.first;

    final query3 = await users
        .where('phone', isEqualTo: candidate3)
        .limit(1)
        .get();
    if (query3.docs.isNotEmpty) return query3.docs.first;

    return null;
  }

  /// Kullanıcı getir (ID ile)
  static Future<DocumentSnapshot?> getUser(String userId) async {
    return await users.doc(userId).get();
  }

  // ==================== BUSINESS ====================

  /// İşletme kaydet (Auth + Firestore)
  static Future<String> registerBusiness({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String district,
  }) async {
    // 0. Telefon Uniqueness Kontrolü
    final existingUser = await getUserByPhone(phone);
    if (existingUser != null) {
      throw Exception(
        'Bu telefon numarası bir kullanıcı hesabı tarafından kullanılıyor.',
      );
    }

    final existingBusiness = await getBusinessByPhone(phone);
    if (existingBusiness != null) {
      throw Exception(
        'Bu telefon numarası başka bir işletme tarafından kullanılıyor.',
      );
    }

    await _auth.setLanguageCode('tr');

    // 1. Auth kaydı
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user!;
    final uid = user.uid;

    // 2. Doğrulama maili gönder
    await user.sendEmailVerification();

    // 3. Firestore kaydı
    await businesses.doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'district': district,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'business',
    });

    // Doğrulanmadığı için oturumu kapat
    await _auth.signOut();

    return uid;
  }

  /// İşletme bul (telefon ile - opsiyonel)
  static Future<DocumentSnapshot?> getBusinessByPhone(String phone) async {
    // 1. Gelen numarayı temizle (sadece rakamlar)
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    String rawNumber = cleaned;

    // Eğer 90 ile başlıyorsa (ülke kodu), onu at ve 10 haneli hale getir
    if (cleaned.startsWith('90') && cleaned.length > 10) {
      rawNumber = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length > 10) {
      // 0 ile başlıyorsa at
      rawNumber = cleaned.substring(1);
    }

    final candidate1 = '+90$rawNumber';
    final candidate2 = '0$rawNumber';
    final candidate3 = rawNumber;

    final query1 = await businesses
        .where('phone', isEqualTo: candidate1)
        .limit(1)
        .get();
    if (query1.docs.isNotEmpty) return query1.docs.first;

    final query2 = await businesses
        .where('phone', isEqualTo: candidate2)
        .limit(1)
        .get();
    if (query2.docs.isNotEmpty) return query2.docs.first;

    final query3 = await businesses
        .where('phone', isEqualTo: candidate3)
        .limit(1)
        .get();
    if (query3.docs.isNotEmpty) return query3.docs.first;

    return null;
  }

  /// İşletme güncelle
  static Future<void> updateBusiness(
    String businessId,
    Map<String, dynamic> data,
  ) async {
    await businesses.doc(businessId).update(data);
  }

  /// Tüm işletmeleri getir
  static Stream<QuerySnapshot> getBusinesses() {
    return businesses.orderBy('createdAt', descending: true).snapshots();
  }

  // ==================== MENU ====================

  /// Menüyü kaydet (Tüm kategorilerle birlikte)
  static Future<void> saveMenu(
    String businessId,
    List<dynamic> categories, // List<MenuCategory>
  ) async {
    // MenuCategory ve MenuItem toMap metodlarını kullanarak JSON'a çeviriyoruz
    final menuJson = categories.map((c) => c.toMap()).toList();
    await businesses.doc(businessId).update({'menu': menuJson});
  }

  /// Menüyü getir (List<MenuCategory> olarak)
  static Stream<List<MenuCategory>> getMenu(String businessId) {
    return businesses.doc(businessId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return [];
      final data = snapshot.data() as Map<String, dynamic>;
      if (!data.containsKey('menu')) return [];

      final menuList = data['menu'] as List<dynamic>;
      return menuList.map((m) => MenuCategory.fromMap(m)).toList();
    });
  }

  /// Menü döküman akışı (Raw)
  static Stream<DocumentSnapshot> getMenuStream(String businessId) {
    return businesses.doc(businessId).snapshots();
  }

  // ==================== ASKI (SUSPENDED MEALS) ====================

  /// Askıya ürün ekle (İşletme veya Bağışçı tarafından)
  static Future<void> addToAski(
    String businessId,
    dynamic item, // MenuItem
    int quantity,
  ) async {
    final askiRef = businesses.doc(businessId).collection('askiItems');

    // Aynı ürün var mı kontrol et
    final query = await askiRef.where('id', isEqualTo: item.id).get();

    if (query.docs.isNotEmpty) {
      // Varsa miktar artır
      final doc = query.docs.first;
      final currentQty = doc['quantity'] as int;
      await doc.reference.update({'quantity': currentQty + quantity});
    } else {
      // Yoksa yeni oluştur
      final newItem = item.toMap();
      newItem['quantity'] = quantity; // Seçilen miktarı ayarla
      newItem['isOnAski'] = true;
      await askiRef.add(newItem);
    }

    // İstatistik güncelle: Toplam askıya eklenen
    await businesses.doc(businessId).update({
      'stats.totalAski': FieldValue.increment(quantity),
    });
  }

  /// Askıdaki ürünleri getir (Miktarı 0'dan büyük olanlar)
  static Stream<QuerySnapshot> getAskiItems(String businessId) {
    return businesses
        .doc(businessId)
        .collection('askiItems')
        .where('quantity', isGreaterThan: 0)
        .snapshots();
  }

  // ==================== RESERVATIONS ====================

  /// Rezervasyon oluştur (Stoktan düşerek)
  static Future<String> createReservation({
    required String visitorId,
    required String businessId,
    required String businessName,
    required dynamic item, // MenuItem
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 30));
    final code = _generateRandomCode();

    // Transaction kullanarak atomik işlem yap (Stok kontrolü + Rezervasyon)
    return await _firestore.runTransaction((transaction) async {
      // 1. Ürünü askıdan bul
      final askiRef = businesses.doc(businessId).collection('askiItems');
      final query = await askiRef.where('id', isEqualTo: item.id).get();

      if (query.docs.isEmpty) {
        throw Exception('Ürün bulunamadı');
      }

      final itemDoc = query.docs.first;
      final currentQty = itemDoc['quantity'] as int;

      if (currentQty < 1) {
        throw Exception('Ürün tükenmiş');
      }

      // 2. Stoğu düş
      transaction.update(itemDoc.reference, {'quantity': currentQty - 1});

      // 3. Rezervasyonu oluştur (Global - Kullanıcı için)
      final resRef = reservations.doc();
      final reservationData = {
        'code': code,
        'visitorId': visitorId,
        'businessId': businessId,
        'businessName': businessName,
        'itemId': item.id,
        'itemName': item.name,
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'status': 'pending',
      };

      transaction.set(resRef, reservationData);

      // 4. Siparişi İşletmenin "orders" (siparişler) koleksiyonuna da ekle
      // (Kullanıcının isteği üzerine işletme reposunda ayrıca tutuluyor)
      final businessOrderRef = businesses
          .doc(businessId)
          .collection('orders')
          .doc(resRef.id); // Aynı ID'yi kullanalım ki eşleşsin

      transaction.set(businessOrderRef, reservationData);

      return code; // Kodu döndür
    });
  }

  static String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
          4,
          (index) => chars[DateTime.now().microsecond % chars.length],
        ).join() +
        '-' +
        List.generate(
          4,
          (index) => chars[DateTime.now().microsecond % chars.length],
        ).join();
  }

  /// Kullanıcının tüm rezervasyonları/siparişleri
  static Stream<QuerySnapshot> getUserReservations(String visitorId) {
    return reservations
        .where('visitorId', isEqualTo: visitorId)
        // .orderBy('createdAt', descending: true) // İndex hatasını önlemek için sıralamayı client tarafında yapacağız
        .snapshots();
  }

  /// İşletmenin rezervasyonları (Bekleyenler öncelikli)
  /// Artık işletmenin kendi 'orders' alt koleksiyonundan çekiyoruz
  static Stream<QuerySnapshot> getBusinessReservations(String businessId) {
    return businesses
        .doc(businessId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Rezervasyon iptal et
  static Future<void> cancelReservation(String reservationId) async {
    // 1. Rezervasyonu oku
    final resDoc = await reservations.doc(reservationId).get();
    if (!resDoc.exists) return;

    final data = resDoc.data() as Map<String, dynamic>;
    if (data['status'] != 'pending')
      return; // Sadece bekleyenler iptal edilebilir

    final businessId = data['businessId'];
    final itemId = data['itemId'];

    // 2. Statusları güncelle
    await reservations.doc(reservationId).update({'status': 'cancelled'});

    try {
      await businesses
          .doc(businessId)
          .collection('orders')
          .doc(reservationId)
          .update({'status': 'cancelled'});
    } catch (e) {
      // İşletme tarafında silinmiş olabilir, önemsiz
    }

    // 3. Stoğu bul ve artır
    // Burada 'id' alanı ile arama yapıyoruz çünkü docID farklı olabilir
    final askiRef = businesses.doc(businessId).collection('askiItems');
    final query = await askiRef.where('id', isEqualTo: itemId).limit(1).get();

    if (query.docs.isNotEmpty) {
      final itemDoc = query.docs.first;
      final currentQty = itemDoc['quantity'] as int;

      // Miktarı 1 artır
      await itemDoc.reference.update({'quantity': currentQty + 1});
    }
  }

  /// Rezervasyon onayla
  static Future<void> confirmReservation(String reservationId) async {
    // Global güncelle
    await reservations.doc(reservationId).update({'status': 'confirmed'});

    // İşletme kopyasını güncelle
    final doc = await reservations.doc(reservationId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final businessId = data['businessId'];

      await businesses
          .doc(businessId)
          .collection('orders')
          .doc(reservationId)
          .update({'status': 'confirmed'});
    }
  }

  /// Rezervasyon onayla (kod ile)
  static Future<Map<String, dynamic>?> verifyReservationCode(
    String businessId,
    String code,
  ) async {
    // İşletmenin kendi orders koleksiyonundan arayalım (Daha hızlı ve güvenli)
    final query = await businesses
        .doc(businessId)
        .collection('orders')
        .where('code', isEqualTo: code.toUpperCase())
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isBefore(expiresAt)) {
        // Kod geçerli, onayla
        await doc.reference.update({'status': 'completed'});

        // Global koleksiyonu da güncelle (User görsün diye)
        await reservations.doc(doc.id).update({'status': 'completed'});

        // İstatistik güncelle: Toplam teslim edilen
        // İstatistik güncelle: Toplam teslim edilen artır, askıdaki düşür
        await businesses.doc(businessId).set({
          'stats': {
            'totalDelivered': FieldValue.increment(1),
            'totalAski': FieldValue.increment(-1),
          },
        }, SetOptions(merge: true));

        return data; // İşlem başarılı
      } else {
        // Süresi dolmuş
        await doc.reference.update({'status': 'expired'});
        await reservations.doc(doc.id).update({'status': 'expired'});

        throw Exception('Kodun süresi dolmuş');
      }
    }
    return null;
  }

  // ==================== MUHTAR ====================

  /// Yardım başvurusu ekle
  static Future<void> addApplication(Map<String, dynamic> data) async {
    await applications.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // pending, reviewed, approved, rejected
    });
  }

  // ==================== DONATIONS ====================

  /// Bağış İşlemi (Hem geçmişe ekle hem de stoğa)
  static Future<void> processDonation({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<MapEntry<dynamic, int>> items,
    required double totalPrice,
  }) async {
    // 1. Bağışı kaydet
    await donations.add({
      'userId': userId,
      'restaurant': restaurantName, // Display name for history
      'restaurantId': restaurantId,
      'items': items
          .length, // Count of unique items types or total count? User UI shows "3 items"
      // Detailed items list could be stored if needed but UI just shows "X items"
      // Let's store total count of products for now to match UI
      'totalItemsCount': items.fold<int>(0, (sum, e) => sum + e.value),
      'amount': totalPrice,
      'date': FieldValue.serverTimestamp(),
      'details': items
          .map(
            (e) => {
              'name': e.key.name,
              'quantity': e.value,
              'price': e.key.price,
            },
          )
          .toList(),
    });

    // 2. Ürünleri askıya ekle
    for (final entry in items) {
      await addToAski(restaurantId, entry.key, entry.value);
    }
  }

  /// Kullanıcının bağışlarını getir
  static Stream<QuerySnapshot> getUserDonations(String userId) {
    return donations.where('userId', isEqualTo: userId).snapshots();
  }
}
