import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/presentation/widget/reservation_edit_sheet.dart';
import 'package:restaurant_menu/repositories/dto/reservation_profile_dto.dart';
import 'package:restaurant_menu/utils/colors.dart' as app_colors;

class ReservationProfileCard extends StatelessWidget {
  final ReservationProfileDto reservation;
  const ReservationProfileCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = reservation.isUpcoming;

    return GestureDetector(
      onTap: () {
        _showEditReservervationSheet(context,reservation);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUpcoming ? app_colors.Colors.primary : CupertinoColors.systemGrey4,
            width: isUpcoming ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: isUpcoming ? app_colors.Colors.primary : CupertinoColors.systemGrey,
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
                    ? app_colors.Colors.primary.withOpacity(0.1)
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                reservation.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUpcoming ? app_colors.Colors.primary : CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReservervationSheet(BuildContext context, ReservationProfileDto reservation) {

    showCupertinoSheet(
      context: context,
      builder: (BuildContext context) => ReservationEditSheet(
        reservation: reservation,
        onSuccess: () {
          _showSuccessMessage(context, 'Réservation mise à jour avec succès');
        },
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        title: const Text('Succès'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }
}
