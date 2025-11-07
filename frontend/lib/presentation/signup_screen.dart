import 'package:flutter/cupertino.dart';
import 'package:restaurant_menu/presentation/main_tab_view.dart';
import 'package:restaurant_menu/utils/colors.dart';
import '../presentation/menu_screen.dart';
import '../presentation/login_screen.dart';
import '../viewmodels/auth_viewmodel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _authViewModel = AuthViewModel();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    // Écouter les changements du ViewModel
    _authViewModel.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _authViewModel.removeListener(_onAuthStateChanged);
    _authViewModel.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_authViewModel.errorMessage != null) {
      _authViewModel.showError(context, _authViewModel.errorMessage!);
      _authViewModel.clearError();
    }

    if (_authViewModel.isAuthenticated && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const MainTabView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        middle: const Text('Inscription'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const MainTabView()),
              (route) => false,
            );
          },
          child: const Text(
            'Passer',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const SizedBox(height: 20),
              // Titre
              const Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rejoignez-nous pour découvrir nos menus',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 32),
              // Nom
              Text(
                'Nom complet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _authViewModel.nameController,
                placeholder: 'Jean Dupont',
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.person, color: CupertinoColors.systemGrey),
                ),
              ),
              const SizedBox(height: 20),
              // Email
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _authViewModel.emailController,
                placeholder: 'votre@email.com',
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
                ),
              ),
              const SizedBox(height: 20),
              // Mot de passe
              Text(
                'Mot de passe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _authViewModel.passwordController,
                placeholder: 'Au moins 6 caractères',
                obscureText: _obscurePassword,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
                ),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Confirmation mot de passe
              Text(
                'Confirmer le mot de passe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _authViewModel.confirmPasswordController,
                placeholder: 'Confirmez votre mot de passe',
                obscureText: _obscureConfirmPassword,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
                ),
                suffix: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  child: Icon(
                    _obscureConfirmPassword
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Bouton inscription
              AnimatedBuilder(
                animation: _authViewModel,
                builder: (context, child) {
                  return SizedBox(
                    height: 54,
                    child: CupertinoButton(
                      color: Colors.primary,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: _authViewModel.isLoading ? null : () => _authViewModel.handleSignup(context),
                      child: _authViewModel.isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Lien connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Déjà un compte ? ',
                    style: TextStyle(color: CupertinoColors.secondaryLabel),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}