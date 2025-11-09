import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../utils/colors.dart';
import '../../viewmodels/admin_reservations_viewmodel.dart';
import '../../repositories/dto/admin_reservation_dto.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final AdminReservationsViewModel _viewModel = AdminReservationsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadPendingReservations();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Réservations en attente'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.refresh),
            onPressed: () => _viewModel.loadPendingReservations(),
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder<bool>(
            valueListenable: _viewModel.isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return const Center(
                  child: CupertinoActivityIndicator(radius: 16),
                );
              }

              return ValueListenableBuilder<List<AdminReservationDTO>>(
                valueListenable: _viewModel.pendingReservations,
                builder: (context, reservations, _) {
                  if (reservations.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildReservationCard(reservations[index]);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.checkmark_alt_circle,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 16),
          Text(
            'Aucune réservation en attente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Toutes les réservations ont été traitées',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(AdminReservationDTO reservation) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey5),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(reservation),
          _buildClientInfo(reservation),
          _buildActionButtons(reservation),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminReservationDTO reservation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.building_2_fill,
            color: Colors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reservation.restaurantName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.primary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'EN ATTENTE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(AdminReservationDTO reservation) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            CupertinoIcons.person_fill,
            'Client',
            reservation.userName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            CupertinoIcons.mail_solid,
            'Email',
            reservation.userEmail,
          ),
          if (reservation.userPhone != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.phone_fill,
              'Téléphone',
              reservation.userPhone!,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: CupertinoColors.systemGrey5,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            CupertinoIcons.calendar,
            'Date',
            _formatDate(reservation.reservationDate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            CupertinoIcons.clock,
            'Heure',
            reservation.reservationTime,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            CupertinoIcons.person_2,
            'Personnes',
            '${reservation.partySize} ${reservation.partySize > 1 ? 'personnes' : 'personne'}',
          ),
          if (reservation.specialRequests != null &&
              reservation.specialRequests!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: CupertinoColors.systemGrey5,
            ),
            const SizedBox(height: 16),
            _buildSpecialRequests(reservation.specialRequests!),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialRequests(String requests) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          CupertinoIcons.doc_text,
          color: CupertinoColors.systemGrey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demandes spéciales',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                requests,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AdminReservationDTO reservation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: CupertinoColors.systemRed,
              borderRadius: BorderRadius.circular(10),
              onPressed: () => _showRejectConfirmation(reservation),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.xmark_circle_fill, size: 18, color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text(
                    'Refuser',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(10),
              onPressed: () => _showAcceptConfirmation(reservation),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.checkmark_circle_fill, size: 18, color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text(
                    'Accepter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: CupertinoColors.systemGrey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      const months = [
        'janvier',
        'février',
        'mars',
        'avril',
        'mai',
        'juin',
        'juillet',
        'août',
        'septembre',
        'octobre',
        'novembre',
        'décembre'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  void _showAcceptConfirmation(AdminReservationDTO reservation) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Accepter la réservation'),
        content: Text(
          'Voulez-vous confirmer la réservation de ${reservation.userName} pour ${reservation.partySize} personne(s) le ${_formatDate(reservation.reservationDate)} à ${reservation.reservationTime} ?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: () async {
              Navigator.of(context).pop();
              await _acceptReservation(reservation.id);
            },
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation(AdminReservationDTO reservation) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Refuser la réservation'),
        content: Text(
          'Voulez-vous refuser la réservation de ${reservation.userName} ?',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await _rejectReservation(reservation.id);
            },
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptReservation(int id) async {
    final success = await _viewModel.acceptReservation(id);
    if (mounted) {
      if (success) {
        _showSuccessMessage('Réservation acceptée avec succès');
      } else {
        _showErrorMessage('Erreur lors de l\'acceptation');
      }
    }
  }

  Future<void> _rejectReservation(int id) async {
    final success = await _viewModel.rejectReservation(id);
    if (mounted) {
      if (success) {
        _showSuccessMessage('Réservation refusée');
      } else {
        _showErrorMessage('Erreur lors du refus');
      }
    }
  }

  void _showSuccessMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Icon(
          CupertinoIcons.checkmark_alt_circle_fill,
          color: CupertinoColors.systemGreen,
          size: 48,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Icon(
          CupertinoIcons.xmark_circle_fill,
          color: CupertinoColors.systemRed,
          size: 48,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
