import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late DateTime selectedDate;
  late DateTime minimumDate;
  String? selectedTime;
  int numberOfGuests = 2;

  final List<String> availableTimes = [
    '12:00', '12:30', '13:00', '13:30', '14:00',
    '19:00', '19:30', '20:00', '20:30', '21:00', '21:30'
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    minimumDate = DateTime(now.year, now.month, now.day);
    selectedDate = minimumDate;
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
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: selectedDate,
              minimumDate: minimumDate,
              maximumDate: minimumDate.add(const Duration(days: 30)),
              onDateTimeChanged: (DateTime date) {
                setState(() {
                  selectedDate = date;
                  selectedTime = null; // Reset time when date changes
                });
              },
            ),
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
          Row(
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
                  setState(() {
                    numberOfGuests--;
                  });
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
                  setState(() {
                    numberOfGuests++;
                  });
                } : null,
              ),
            ],
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
        GridView.builder(
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
                setState(() {
                  selectedTime = time;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.primary
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.primary
                        : CupertinoColors.systemGrey4,
                  ),
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
        ),
      ],
    );
  }

  Widget _buildReserveButton() {
    final isEnabled = selectedTime != null;

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
          child: const Text(
            'Réserver',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _handleReservation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Réservation confirmée'),
        content: Text(
          'Votre table pour $numberOfGuests personne${numberOfGuests > 1 ? 's' : ''} '
              'le ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} '
              'à $selectedTime a été réservée.',
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
