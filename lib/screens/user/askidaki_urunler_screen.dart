import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant.dart';
import '../../services/firebase_service.dart';
import '../../widgets/user/restaurant_card.dart';
import 'restaurant_menu_screen.dart';

class AskidakiUrunlerScreen extends StatelessWidget {
  final Function(Restaurant) onReserve;

  const AskidakiUrunlerScreen({super.key, required this.onReserve});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getBusinesses(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Henüz kayıtlı işletme yok.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final restaurant = Restaurant.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            return RestaurantCard(
              restaurant: restaurant,
              buttonText: 'Rezerve\nEt',
              onButtonPressed: () => onReserve(restaurant),
            );
          },
        );
      },
    );
  }
}

class AskiyaEkleScreen extends StatelessWidget {
  const AskiyaEkleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getBusinesses(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Henüz kayıtlı işletme yok.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final restaurant = Restaurant.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );

            return RestaurantCard(
              restaurant: restaurant,
              buttonText: 'Bağış\nYap',
              showAskiCount: false,
              onButtonPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantMenuScreen(restaurant: restaurant),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
