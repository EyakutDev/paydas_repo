import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../widgets/user/restaurant_card.dart';
import 'restaurant_menu_screen.dart';

class AskidakiUrunlerScreen extends StatelessWidget {
  final Function(Restaurant) onReserve;

  const AskidakiUrunlerScreen({super.key, required this.onReserve});

  // Demo restoranlar
  List<Restaurant> get _demoRestaurants => [
    Restaurant.demo(
      id: '1',
      name: 'Atakan Döner',
      distance: '800m uzakta',
      askiItemCount: 5,
    ),
    Restaurant.demo(
      id: '2',
      name: 'Lezzet Durağı',
      distance: '1.2km uzakta',
      askiItemCount: 3,
    ),
    Restaurant.demo(
      id: '3',
      name: 'Anadolu Sofrası',
      distance: '500m uzakta',
      askiItemCount: 8,
    ),
    Restaurant.demo(
      id: '4',
      name: 'Pide House',
      distance: '2km uzakta',
      askiItemCount: 2,
    ),
    Restaurant.demo(
      id: '5',
      name: 'Köfteci Yusuf',
      distance: '1.5km uzakta',
      askiItemCount: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _demoRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _demoRestaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          buttonText: 'Rezerve\nEt',
          onButtonPressed: () => onReserve(restaurant),
        );
      },
    );
  }
}

class AskiyaEkleScreen extends StatelessWidget {
  const AskiyaEkleScreen({super.key});

  // Demo restoranlar
  List<Restaurant> get _demoRestaurants => [
    Restaurant.demo(
      id: '1',
      name: 'Atakan Döner',
      distance: '800m uzakta',
      askiItemCount: 0,
    ),
    Restaurant.demo(
      id: '2',
      name: 'Lezzet Durağı',
      distance: '1.2km uzakta',
      askiItemCount: 0,
    ),
    Restaurant.demo(
      id: '3',
      name: 'Anadolu Sofrası',
      distance: '500m uzakta',
      askiItemCount: 0,
    ),
    Restaurant.demo(
      id: '4',
      name: 'Pide House',
      distance: '2km uzakta',
      askiItemCount: 0,
    ),
    Restaurant.demo(
      id: '5',
      name: 'Köfteci Yusuf',
      distance: '1.5km uzakta',
      askiItemCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _demoRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _demoRestaurants[index];
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
  }
}
