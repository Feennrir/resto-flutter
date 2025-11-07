import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/presentation/profil_screen.dart';
import '../utils/colors.dart';
import 'restaurant_presentation_screen.dart';
import 'reservation_screen.dart';

class MainTabView extends StatelessWidget {
  const MainTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Colors.primary,
        inactiveColor: CupertinoColors.systemGrey,
        backgroundColor: CupertinoColors.systemBackground,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Réservation',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profil',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const RestaurantPresentationScreen();
          case 1:
            return const ReservationScreen();
          case 2:
            return const ProfileScreen();
          default:
            return const RestaurantPresentationScreen();
        }
      },
    );
  }
}
