import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
// import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/presentation/screens/main_navigation_screen.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import '../providers/auth_provider.dart';

const List<String> _backgroundImages = [
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
];

/*
// secure storage keys for remembered credentials
const _keyRememberMe = 'remember_me';
const _keyRememberedEmail = 'remembered_email';
const _keyRememberedPassword = 'remembered_password';
*/

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgIndex = useState(0);
    final isLoading = useState(false);
    // final rememberMe = useState(false);

    // cycle background images every 5 seconds
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (_) {
        bgIndex.value = (bgIndex.value + 1) % _backgroundImages.length;
      });
      return timer.cancel;
    }, []);

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final obscure = useState(true);

    /*
    // load saved credentials on mount
    useEffect(() {
      Future<void> load() async {
        final prefs = SharedPrefsService();
        await prefs.init();
        final saved = prefs.readBool(_keyRememberMe) ?? false;
        if (saved) {
          final secure = SecureStorageService();
          final email = await secure.read(_keyRememberedEmail);
          final password = await secure.read(_keyRememberedPassword);
          if (email != null) emailCtrl.text = email;
          if (password != null) passwordCtrl.text = password;
          rememberMe.value = true;
        }
      }

      load();
      return null;
    }, []);
    */

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      isLoading.value = true;
      final error = await ref
          .read(authProvider.notifier)
          .loginWithEmail(emailCtrl.text.trim(), passwordCtrl.text);
      isLoading.value = false;

      if (!context.mounted) return;
      if (error != null) {
        AppSnackbar.showError(context, error);
      } else {
        /*
        // persist or clear credentials based on checkbox
        final prefs = SharedPrefsService();
        final secure = SecureStorageService();
        if (rememberMe.value) {
          await prefs.writeBool(_keyRememberMe, true);
          await secure.write(_keyRememberedEmail, emailCtrl.text.trim());
          await secure.write(_keyRememberedPassword, passwordCtrl.text);
        } else {
          await prefs.writeBool(_keyRememberMe, false);
          await secure.delete(_keyRememberedEmail);
          await secure.delete(_keyRememberedPassword);
        }
        */

        // pre-fetch user profile so home & store screens have data immediately
        ref.invalidate(userProfileProvider);
        // ignore errors — screens will handle their own error/retry states
        ref.read(userProfileProvider.future).ignore();

        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (_) => false,
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // cycling background
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Image.network(
              _backgroundImages[bgIndex.value],
              key: ValueKey(bgIndex.value),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(color: Colors.black87),
            ),
          ),
          // dark overlay
          Container(color: Colors.black.withOpacity(0.35)),
          // card content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // logo
                      Image.asset(
                        'assets/images/logo/logo-no-bg.png',
                        height: 36,
                        errorBuilder: (_, __, ___) => Row(
                          children: [
                            const Icon(Icons.point_of_sale, size: 28),
                            const SizedBox(width: 6),
                            Text(
                              'POS',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome to 01 POS',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Email'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.validateEmail,
                              decoration: const InputDecoration(
                                hintText: 'youremail@mail.com',
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FieldLabel('Password'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: passwordCtrl,
                              obscureText: obscure.value,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => submit(),
                              validator: Validators.validatePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppTheme.grey500,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      obscure.value = !obscure.value,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // remember me + forgot password row
                            Row(
                              children: [
                                /*
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: rememberMe.value,
                                    onChanged: (v) =>
                                        rememberMe.value = v ?? false,
                                    activeColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(
                                      color: AppTheme.grey500,
                                      width: 1.5,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      rememberMe.value = !rememberMe.value,
                                  child: Text(
                                    'Remember me',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                */
                                const Spacer(),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.resetPassword,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.blue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            _LoginButton(
                              onPressed: submit,
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed, required this.isLoading});

  final VoidCallback onPressed;
  final ValueNotifier<bool> isLoading;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (_, loading, __) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
