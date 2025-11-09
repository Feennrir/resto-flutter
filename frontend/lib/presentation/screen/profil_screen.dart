import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restaurant_menu/presentation/welcome_screen.dart';
import 'package:restaurant_menu/presentation/widget/edit_profil_form.dart';
import 'package:restaurant_menu/presentation/widget/profil_user_section.dart';

import '../../models/user.dart';
import '../../repositories/dto/reservation_profile_dto.dart';
import '../../utils/colors.dart' as app_colors;
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widget/reservation_profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileViewModel _profileViewModel = ProfileViewModel();
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    _profileViewModel.errorMessageNotifier.addListener(_onErrorChanged);
    _authViewModel.addListener(_onAuthChanged);
    _checkAuthAndLoadProfile();
  }

  @override
  void dispose() {
    _profileViewModel.errorMessageNotifier.removeListener(_onErrorChanged);
    _authViewModel.removeListener(_onAuthChanged);
    _profileViewModel.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Profil'),
          trailing: _authViewModel.isAuthenticated
              ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showLogoutConfirmation,
            child: const Icon(
              CupertinoIcons.square_arrow_right,
              color: CupertinoColors.destructiveRed,
            ),
          )
              : null,
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  void _onErrorChanged() {
    final errorMessage = _profileViewModel.errorMessageNotifier.value;
    if (errorMessage != null) {
      if (!errorMessage.contains('non authentifié') &&
          !errorMessage.contains('Session expirée')) {
        _showError(errorMessage);
      }
      _profileViewModel.clearError();
    }
  }

  void _onAuthChanged() {
    if (_authViewModel.isAuthenticated) {
      _loadProfile();
    } else {
      _profileViewModel.clear();
    }
    setState(() {});
  }

  Future<void> _checkAuthAndLoadProfile() async {
    await _authViewModel.initialize();
    if (_authViewModel.isAuthenticated) {
      await _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    await _profileViewModel.loadProfile();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await _authViewModel.logout();
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<bool>(
      valueListenable: _profileViewModel.isLoadingNotifier,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<User?>(
          valueListenable: _profileViewModel.userNotifier,
          builder: (context, user, _) {
            if (_authViewModel.isLoading || (isLoading && user == null)) {
              return const Center(child: CupertinoActivityIndicator());
            }

            // Si l'utilisateur n'est pas connecté
            if (!_authViewModel.isAuthenticated) {
              return WelcomeScreen();
            }

            // Si erreur de chargement du profil
            if (user == null) {
              return _buildErrorState();
            }

            // Afficher le profil
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  ProfilUserSection(user: user),
                  const SizedBox(height: 24),
                  _buildReservationsSection(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 80,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Impossible de charger le profil',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('Réessayer'),
            onPressed: _loadProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    final joinYear = user.getJoinYear();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: app_colors.Colors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 40,
              color: app_colors.Colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            joinYear.isNotEmpty
                ? 'Client fidèle depuis $joinYear'
                : 'Nouveau client',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildReservationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mes réservations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<ReservationProfileDto>>(
          valueListenable: _profileViewModel.reservations,
          builder: (context, reservations, _) {
            if (reservations.isEmpty) {
              return const Text(
                'Vous n\'avez pas encore de réservations.',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              );
            }

            return Column(
              children: reservations.map((reservation) {
                return GestureDetector(
                  onTap: () => {},
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ReservationProfileCard(
                      reservation: reservation,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
