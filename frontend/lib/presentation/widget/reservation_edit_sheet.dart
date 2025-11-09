import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_menu/repositories/dto/reservation_profile_dto.dart';
import 'package:restaurant_menu/utils/colors.dart' as app_colors;
import 'package:restaurant_menu/viewmodels/profile_viewmodel.dart';

import '../../viewmodels/reservation_edit_viewmodel.dart';

class ReservationEditSheet extends StatefulWidget {
  final ReservationProfileDto reservation;
  final VoidCallback onSuccess;

  const ReservationEditSheet({
    required this.reservation,
    required this.onSuccess,
  });

  @override
  State<ReservationEditSheet> createState() => _ReservationEditSheetState();
}

class _ReservationEditSheetState extends State<ReservationEditSheet> {
  final ReservationEditSheetModel profileViewModel = ReservationEditSheetModel();

  bool isEditing = false;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late int selectedGuests;
  late TextEditingController specialRequestsController;

  @override
  void initState() {
    super.initState();

    // Parser la date
    try {
      selectedDate = DateTime.parse(widget.reservation.date);
    } catch (e) {
      final parts = widget.reservation.date.split('/');
      if (parts.length == 3) {
        selectedDate = DateTime(
          int.parse(parts[2]), // année
          int.parse(parts[1]), // mois
          int.parse(parts[0]), // jour
        );
      } else {
        selectedDate = DateTime.now();
      }
    }

    selectedTime = TimeOfDay(
      hour: int.parse(widget.reservation.time.split(':')[0]),
      minute: int.parse(widget.reservation.time.split(':')[1]),
    );
    selectedGuests = widget.reservation.guests;
    specialRequestsController = TextEditingController(
      text: widget.reservation.specialRequests ?? '',
    );
  }

  @override
  void dispose() {
    specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  Text(
                    isEditing ? 'Modifier la réservation' : 'Détails de la réservation',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: isEditing ? _buildEditContent() : _buildDisplayContent(),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: isEditing ? _buildEditButtons() : _buildDisplayButtons(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayContent() {
    return Column(
      children: [
        // Carte principale avec statut
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.reservation.isUpcoming
                  ? [app_colors.Colors.primary, app_colors.Colors.primary.withOpacity(0.8)]
                  : [CupertinoColors.systemGrey, CupertinoColors.systemGrey2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: app_colors.Colors.primary.withOpacity(0.2),
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
                      color: app_colors.Colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reservation.isUpcoming ? 'À venir' : 'Passée',
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
                  widget.reservation.status.toUpperCase(),
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
                widget.reservation.date,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                CupertinoIcons.clock,
                'Heure',
                widget.reservation.time,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                CupertinoIcons.person_2,
                'Convives',
                '${widget.reservation.guests} personne${widget.reservation.guests > 1 ? 's' : ''}',
              ),
              if (widget.reservation.specialRequests?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  CupertinoIcons.chat_bubble_text,
                  'Demandes spéciales',
                  widget.reservation.specialRequests!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Date et Heure
        _buildSectionHeader('Date et heure'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 200,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              ),
              minimumDate: DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  selectedDate = newDateTime;
                  selectedTime = TimeOfDay.fromDateTime(newDateTime);
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Section Nombre de convives
        _buildSectionHeader('Nombre de convives'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 120,
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: FixedExtentScrollController(
                initialItem: selectedGuests - 1,
              ),
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedGuests = index + 1;
                });
              },
              children: List.generate(
                10,
                    (index) => Center(
                  child: Text(
                    '${index + 1} personne${index + 1 > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Section Demandes spéciales
        _buildSectionHeader('Demandes spéciales'),
        const SizedBox(height: 12),
        CupertinoTextField(
          controller: specialRequestsController,
          placeholder: 'Ajoutez vos demandes spéciales (optionnel)...',
          maxLines: 4,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayButtons() {
    if (!widget.reservation.isUpcoming) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: CupertinoColors.systemRed,
            borderRadius: BorderRadius.circular(12),
            onPressed: () async{
              final bool? confirm = await showCupertinoDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) => CupertinoAlertDialog(
                  title: const Text('Confirmer l\'annulation'),
                  content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Non'),
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text('Oui, annuler'),
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                  ],
                ),
              );

              // Si l'utilisateur a confirmé, procéder à l'annulation
              if (confirm == true) {
                await profileViewModel.cancelReservation(widget.reservation).then((_) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              }
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
            color: app_colors.Colors.primary,
            borderRadius: BorderRadius.circular(12),
            onPressed: () {
              setState(() {
                isEditing = true;
              });
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
    );
  }

  Widget _buildEditButtons() {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text('Annuler'),
            onPressed: () {
              setState(() {
                isEditing = false;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: profileViewModel.isLoading,
            builder: (context, isLoading, _) {
              return CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: isLoading ? null : _saveChanges,
                child: isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : const Text(
                  'Confirmer',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    await profileViewModel.updateReservation(
      oldReservation: widget.reservation,
      date: selectedDate,
      time: selectedTime,
      guests: selectedGuests,
      specialRequests: specialRequestsController.text.trim(),
    );
      setState(() {
      });
      Navigator.pop(context);
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: app_colors.Colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: app_colors.Colors.primary,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
    );
  }
}