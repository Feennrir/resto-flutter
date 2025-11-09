import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restaurant_menu/models/user.dart';
import 'package:restaurant_menu/presentation/widget/edit_profil_form.dart';
import 'package:restaurant_menu/utils/colors.dart' as app_colors;

class ProfilUserSection extends StatefulWidget {
  final User user;
  const ProfilUserSection({super.key, required this.user});

  @override
  State<ProfilUserSection> createState() => _ProfilUserSectionState();
}

class _ProfilUserSectionState extends State<ProfilUserSection> {
  @override
  Widget build(BuildContext context) {
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
          _buildInfoRow(CupertinoIcons.mail, 'Email', widget.user.email),
          const SizedBox(height: 12),
          _buildInfoRow(
            CupertinoIcons.phone,
            'Téléphone',
            widget.user.phone ?? 'Non renseigné',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(8),
              onPressed: _showEditProfileSheet,
              child: const Text('Modifier les informations'),
            ),
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
          color: app_colors.Colors.primary,
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

  void _showEditProfileSheet() {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext context) => EditProfilForm(user: widget.user),
    );
  }
}
