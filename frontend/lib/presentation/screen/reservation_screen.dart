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
        const SizedBox(height: 12),
        ValueListenableBuilder<List<String>>(
          valueListenable: viewModel.availableTimes,
          builder: (context, availableTimes, child) {
            if (availableTimes.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Aucun horaire disponible pour cette date',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 16,
                    ),
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
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: availableTimes.length,
                  itemBuilder: (context, index) {
                    final time = availableTimes[index];
                    final isSelected = selectedTime == time;

                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        viewModel.updateSelectedTime(time);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.primary
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
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
