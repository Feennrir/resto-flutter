import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../models/user.dart';
import '../../viewmodels/profile_edit_viewmodel.dart';

class EditProfilForm extends StatefulWidget {
  final User user;
  const EditProfilForm({super.key, required this.user});

  @override
  State<EditProfilForm> createState() => _EditProfilFormState();
}

class _EditProfilFormState extends State<EditProfilForm> {
  final EditProfileViewModel _editProfileViewModel = EditProfileViewModel();

  @override
  void initState() {
    _editProfileViewModel.nameController.text = widget.user.name;
    _editProfileViewModel.phoneController.text = widget.user.phone ?? '';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                    valueListenable: _editProfileViewModel.isSaving,
                    builder: (context, isLoading, _) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _editProfileViewModel.updateProfile(
                          name: _editProfileViewModel.nameController.text.trim(),
                          phone: _editProfileViewModel.phoneController.text.trim().isEmpty
                              ? null
                              : _editProfileViewModel.phoneController.text.trim(),
                        ).then((success) {
                          if (success) {
                            Navigator.pop(context);
                            _showSuccessMessage(
                                'Profil mis à jour avec succès');
                          }
                        }),
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
                  controller: _editProfileViewModel.nameController,
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
                  controller: _editProfileViewModel.phoneController,
                  placeholder: 'Optionnel',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                          widget.user.email,
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
      )
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

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
