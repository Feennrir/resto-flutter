import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_menu/viewmodels/reservation_screen_viewmodel.dart';
import '../../utils/colors.dart';

class ReservationScreen extends StatefulWidget {

  const ReservationScreen({
    super.key,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late ReservationScreenViewModel viewModel;
  late TextEditingController specialRequestsController;
  final String restaurantId = '1';

  @override
  void initState() {
    super.initState();
    viewModel = ReservationScreenViewModel();
    specialRequestsController = TextEditingController();

    // Initialize with current date and load available times
    final now = DateTime.now();
    viewModel.selectedDate.value = now;
    viewModel.minimumDate.value = now;
    _loadAvailableTimes(restaurantId);

    // Listen to date changes to reload available times
    viewModel.selectedDate.addListener(_onDateChanged);
  }

  @override
  void dispose() {
    specialRequestsController.dispose();
    viewModel.selectedDate.removeListener(_onDateChanged);
    viewModel.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    _loadAvailableTimes(restaurantId);
  }

  Future<void> _loadAvailableTimes(String restaurantId) async {
    await viewModel.getAvailableTimeSlots(
      restaurantId: restaurantId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Réservation'),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateSelection(),
                      const SizedBox(height: 24),
                      _buildGuestSelection(),
                      const SizedBox(height: 24),
                      _buildTimeSelection(),
                      const SizedBox(height: 24),
                      _buildSpecialRequestsField(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildReserveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
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
            'Sélectionner une date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<DateTime>(
            valueListenable: viewModel.selectedDate,
            builder: (context, selectedDate, child) {
              return ValueListenableBuilder<DateTime>(
                valueListenable: viewModel.minimumDate,
                builder: (context, minimumDate, child) {
                  final safeDateToShow = selectedDate.isBefore(minimumDate)
                      ? minimumDate
                      : selectedDate;

                  return SizedBox(
                    height: 180,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: safeDateToShow,
                      minimumDate: minimumDate,
                      maximumDate: minimumDate.add(const Duration(days: 30)),
                      onDateTimeChanged: (DateTime date) {
                        viewModel.updateSelectedDate(date);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSelection() {
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
            'Nombre de convives',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<int>(
            valueListenable: viewModel.numberOfGuests,
            builder: (context, numberOfGuests, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.minus,
                        color: CupertinoColors.white,
                      ),
                    ),
                    onPressed: numberOfGuests > 1 ? () {
                      viewModel.updateNumberOfGuests(numberOfGuests - 1);
                    } : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '$numberOfGuests',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.activeGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.plus,
                        color: CupertinoColors.white,
                      ),
                    ),
                    onPressed: numberOfGuests < 8 ? () {
                      viewModel.updateNumberOfGuests(numberOfGuests + 1);
                    } : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horaires disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: viewModel.availableTimes,
          builder: (context, availableTimes, child) {
            if (availableTimes.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.calendar_badge_minus,
                        size: 48,
                        color: CupertinoColors.systemGrey.withOpacity(0.6),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Aucun horaire disponible',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Veuillez sélectionner une autre date',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ValueListenableBuilder<String?>(
              valueListenable: viewModel.selectedTime,
              builder: (context, selectedTime, child) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: availableTimes.length,
                  itemBuilder: (context, index) {
                    final slot = availableTimes[index];
                    final time = slot['time'] as String;
                    final availableSpaces = slot['availableSpaces'] as int;
                    final maxCapacity = slot['maxCapacity'] as int;
                    final isSelected = selectedTime == time;
                    final occupancyRate = availableSpaces / maxCapacity;
                    
                    // Déterminer la couleur selon la disponibilité
                    Color statusColor;
                    if (occupancyRate > 0.5) {
                      statusColor = CupertinoColors.activeGreen;
                    } else if (occupancyRate > 0.25) {
                      statusColor = CupertinoColors.systemOrange;
                    } else {
                      statusColor = CupertinoColors.systemRed;
                    }

                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        viewModel.updateSelectedTime(time);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.primary,
                                    Colors.primary.withOpacity(0.8),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.primary
                                : CupertinoColors.systemGrey4,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.clock,
                                    size: 16,
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : CupertinoColors.systemGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: isSelected
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? CupertinoColors.white.withOpacity(0.2)
                                      : statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_2_fill,
                                      size: 12,
                                      color: isSelected
                                          ? CupertinoColors.white
                                          : statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$availableSpaces/$maxCapacity',
                                      style: TextStyle(
                                        color: isSelected
                                            ? CupertinoColors.white
                                            : statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecialRequestsField() {
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
            'Demandes spéciales (optionnel)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: specialRequestsController,
            placeholder: 'Allergies, préférences de table, etc...',
            maxLines: 3,
            onChanged: (value) {
              viewModel.updateSpecialRequests(value);
            },
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReserveButton() {
    return ValueListenableBuilder<String?>(
      valueListenable: viewModel.selectedTime,
      builder: (context, selectedTime, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: viewModel.isLoading,
          builder: (context, isLoading, child) {
            final isEnabled = selectedTime != null && !isLoading;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: isEnabled ? _handleReservation : null,
                  child: isLoading
                      ? const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                  )
                      : const Text(
                    'Réserver',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleReservation() async {
    try {
      await viewModel.createReservation(
        restaurantId: restaurantId,
      );

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Réservation confirmée'),
            content: ValueListenableBuilder<int>(
              valueListenable: viewModel.numberOfGuests,
              builder: (context, numberOfGuests, child) {
                return ValueListenableBuilder<DateTime>(
                  valueListenable: viewModel.selectedDate,
                  builder: (context, selectedDate, child) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: viewModel.selectedTime,
                      builder: (context, selectedTime, child) {
                        return Text(
                          'Votre table pour $numberOfGuests personne${numberOfGuests > 1 ? 's' : ''} '
                              'le ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} '
                              'à $selectedTime a été réservée.',
                        );
                      },
                    );
                  },
                );
              },
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
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Erreur'),
            content: Text('Erreur lors de la réservation: $e'),
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
  }
}
