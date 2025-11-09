import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restaurant_menu/models/reservation.dart';

import '../../models/user.dart';
import '../../repositories/dto/reservation_profile_dto.dart';
import '../../utils/colors.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileViewModel _profileViewModel = ProfileViewModel();
  final AuthViewModel _authViewModel = AuthViewModel();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

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
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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

  void _showEditProfileSheet() {
    final user = _profileViewModel.userNotifier.value;
    if (user == null) return;

    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';

    showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // En-tête de la sheet
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const Text(
                      'Modifier le profil',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _profileViewModel.isLoadingNotifier,
                      builder: (context, isLoading, _) {
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final success =
                                      await _profileViewModel.updateProfile(
                                    name: _nameController.text.trim(),
                                    phone: _phoneController.text.trim().isEmpty
                                        ? null
                                        : _phoneController.text.trim(),
                                  );

                                  if (success && mounted) {
                                    Navigator.pop(context);
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) =>
                                          CupertinoAlertDialog(
                                        title: const Text('Succès'),
                                        content: const Text(
                                            'Profil mis à jour avec succès'),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text('OK'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                          child: isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text(
                                  'Enregistrer',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Contenu du formulaire
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Nom
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nom complet',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _nameController,
                          placeholder: 'Entrez votre nom',
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(
                              CupertinoIcons.person,
                              color: CupertinoColors.systemGrey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Téléphone
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Numéro de téléphone',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _phoneController,
                          placeholder: 'Optionnel',
                          keyboardType: TextInputType.phone,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(
                              CupertinoIcons.phone,
                              color: CupertinoColors.systemGrey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Email (non modifiable)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.mail,
                                color: CupertinoColors.systemGrey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'L\'email ne peut pas être modifié',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              return _buildLoginPrompt();
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
                  _buildUserInfo(user),
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

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.person_crop_circle,
                size: 60,
                color: Colors.primary,
              ),
            ),
            const SizedBox(height: 32),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Titre
                const Text(
                  'Connectez-vous',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                const Text(
                  'Accédez à votre profil et gérez vos réservations en vous connectant à votre compte.',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.secondaryLabel,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 40),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: CupertinoButton(
                    color: Colors.primary,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.lock_open,
                            size: 20, color: CupertinoColors.white),
                        SizedBox(width: 8),
                        Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Avantages
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildBenefitRow(
                        CupertinoIcons.calendar_badge_plus,
                        'Réserver une table facilement',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitRow(
                        CupertinoIcons.clock,
                        'Consulter l\'historique de vos réservations',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
        color: Colors.primary,
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
              color: Colors.primary,
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

  Widget _buildUserInfo(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(CupertinoIcons.mail, 'Email', user.email),
          const SizedBox(height: 12),
          _buildInfoRow(
            CupertinoIcons.phone,
            'Téléphone',
            user.phone ?? 'Non renseigné',
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: _profileViewModel.isLoadingNotifier,
            builder: (context, isLoading, _) {
              return SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(8),
                  onPressed: isLoading ? null : _showEditProfileSheet,
                  child: isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : const Text('Modifier les informations'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
        ..._profileViewModel.reservations.value
            .map((reservation) => _buildReservationCard(reservation)),
      ],
    );
  }

  Widget _buildReservationCard(ReservationProfileDto reservation) {
    final isUpcoming = reservation.isUpcoming;

    return GestureDetector(
      onTap: () {
        _showEditReservervationSheet(reservation);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUpcoming ? Colors.primary : CupertinoColors.systemGrey4,
            width: isUpcoming ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: isUpcoming ? Colors.primary : CupertinoColors.systemGrey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reservation.date} à ${reservation.time}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${reservation.guests} personne${reservation.guests > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? Colors.primary.withOpacity(0.1)
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                reservation.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUpcoming ? Colors.primary : CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReservervationSheet(ReservationProfileDto reservation) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey3,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // En-tête
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                    const Text(
                      'Détails de la réservation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carte principale avec statut
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: reservation.isUpcoming
                                ? [Colors.primary, Colors.primary.withOpacity(0.8)]
                                : [CupertinoColors.systemGrey, CupertinoColors.systemGrey2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: CupertinoColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.calendar,
                                    color: Colors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reservation.isUpcoming ? 'À venir' : 'Passée',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                reservation.status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Informations détaillées
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              CupertinoIcons.calendar_today,
                              'Date',
                              reservation.date,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              CupertinoIcons.clock,
                              'Heure',
                              reservation.time,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              CupertinoIcons.person_2,
                              'Convives',
                              '${reservation.guests} personne${reservation.guests > 1 ? 's' : ''}',
                            ),
                            // if (reservation.specialRequests?.isNotEmpty == true) ...[
                            //   const SizedBox(height: 16),
                            //   _buildDetailRow(
                            //     CupertinoIcons.chat_bubble_text,
                            //     'Demandes spéciales',
                            //     reservation.specialRequests!,
                            //   ),
                            // ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      if (reservation.isUpcoming) ...[
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                color: CupertinoColors.systemRed,
                                borderRadius: BorderRadius.circular(12),
                                onPressed: () {
                                  _showCancelConfirmation(reservation);
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.xmark_circle, size: 18, color: CupertinoColors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Annuler',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                color: Colors.primary,
                                borderRadius: BorderRadius.circular(12),
                                onPressed: () {
                                  _showModifyOptions(reservation);
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.pencil, size: 18, color: CupertinoColors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Modifier',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmation(ReservationProfileDto reservation) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Non'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              _profileViewModel.cancelReservation(reservation.id);
              Navigator.pop(context);
            },
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showModifyOptions(ReservationProfileDto reservation) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Modifier la réservation'),
      message: const Text('Que souhaitez-vous modifier ?'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Modifier la date/heure
          },
          child: const Text('Date et heure'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Modifier le nombre de personnes
          },
          child: const Text('Nombre de convives'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Modifier les demandes spéciales
          },
          child: const Text('Demandes spéciales'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      )
    );
  }
}
