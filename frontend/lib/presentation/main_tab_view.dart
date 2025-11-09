import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/presentation/screen/profil_screen.dart';
import 'package:restaurant_menu/presentation/screen/restaurant_presentation_screen.dart';
import '../utils/colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'screen/reservation_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    _authViewModel.initialize();
    _authViewModel.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    _authViewModel.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  List<BottomNavigationBarItem> _buildTabItems() {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.home),
        label: 'Accueil',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.calendar),
        label: 'Réservation',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        label: 'Profil',
      ),
    ];

    // Ajouter l'onglet Admin si l'utilisateur est admin
    if (_authViewModel.isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.shield_fill),
          label: 'Admin',
        ),
      );
    }

    return items;
  }

  Widget _buildTab(int index) {

    if (_authViewModel.isAdmin) {
      // Si admin, 4 onglets
      switch (index) {
        case 0:
          return const RestaurantPresentationScreen();
        case 1:
          return const ReservationScreen();
        case 2:
          return const ProfileScreen();
        case 3:
          return const AdminDashboardScreen();
        default:
          return const RestaurantPresentationScreen();
      }
    } else {
      // Si non admin, 3 onglets
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
    }
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Colors.primary,
        inactiveColor: CupertinoColors.systemGrey,
        backgroundColor: CupertinoColors.systemBackground,
        items: _buildTabItems(),
      ),
      tabBuilder: (context, index) => _buildTab(index),
    );
  }
}
