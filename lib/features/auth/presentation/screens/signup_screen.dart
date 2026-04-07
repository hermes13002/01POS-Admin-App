import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/animated_background.dart';
import 'package:onepos_admin_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const List<String> _backgroundImages = [
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
];

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isLoading = useState(false);

    final businessNameCtrl = useTextEditingController();
    final businessEmailCtrl = useTextEditingController();
    final whatsappCtrl = useTextEditingController();

    final industryType = useState<String?>(null);
    final agreedToTerms = useState(false);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      if (industryType.value == null) {
        AppSnackbar.showError(context, 'Please select an industry type');
        return;
      }
      if (!agreedToTerms.value) {
        AppSnackbar.showError(
          context,
          'You must agree to the terms and privacy policy',
        );
        return;
      }

      isLoading.value = true;

      final body = {
        "company_name": businessNameCtrl.text.trim(),
        "company_email": businessEmailCtrl.text.trim(),
        "company_address": "14, lagos", // handled by admin
        "company_number": whatsappCtrl.text.trim(),
        "company_type": industryType.value,
        "password": "", // handled by admin
        // "captcha_token": '',
      };

      final error = await ref.read(authProvider.notifier).signUp(body);
      isLoading.value = false;

      if (!context.mounted) return;
      if (error != null) {
        AppSnackbar.showError(context, error);
      } else {
        AppSnackbar.showSuccess(
          context,
          'Account created successfully! Please login.',
        );
        Navigator.pop(context); // Go back to login
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // cycling background
          AnimatedBackground(images: _backgroundImages),
          // card content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 32,
                  bottom: 0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo/logo-no-bg.png',
                          height: 36,
                          errorBuilder: (_, __, ___) => Row(
                            children: [
                              const Icon(Icons.point_of_sale, size: 28),
                              const SizedBox(width: 6),
                              Text(
                                '01POS',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          "Let's create your account",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Business Name
                        const _FieldLabel('Business name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: businessNameCtrl,
                          textInputAction: TextInputAction.next,
                          validator: (val) =>
                              Validators.validateRequired(val, 'Business name'),
                          decoration: InputDecoration(
                            hintText: 'business name',
                            hintStyle: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.grey300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.grey300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Business Email
                        const _FieldLabel('Business email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: businessEmailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateEmail,
                          decoration: InputDecoration(
                            hintText: 'youremail@mail.com',
                            hintStyle: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.grey300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.grey300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // WhatsApp Number
                        RichText(
                          text: TextSpan(
                            text: 'WhatsApp Number ',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: '(optional - for setup help)',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: whatsappCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: '080 1234 5678',
                            hintStyle: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.grey300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.grey300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Industry Type
                        const _FieldLabel('Industry type'),
                        const SizedBox(height: 8),
                        AppDropdown<String>(
                          hint: 'Select industry type',
                          value: industryType.value,
                          items:
                              [
                                    'Retail',
                                    'Services',
                                    'Pharmacy / Health',
                                    'Hotel / Shortlet',
                                    'Salon / Beauty',
                                    'Bar / Lounge',
                                    'Supermarket / Grocery',
                                    'E-commerce / Online Store',
                                    'Others',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => industryType.value = val,
                        ),
                        const SizedBox(height: 24),

                        // Terms Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: agreedToTerms.value,
                                onChanged: (val) =>
                                    agreedToTerms.value = val ?? false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to '),
                                    TextSpan(
                                      text: '01pos terms',
                                      style: const TextStyle(
                                        color: AppTheme.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => launchUrl(
                                          Uri.parse(
                                            'https://01pos.net/ng/privacy-policy',
                                          ),
                                        ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'privacy policy.',
                                      style: const TextStyle(
                                        color: AppTheme.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => launchUrl(
                                          Uri.parse(
                                            'https://01pos.net/ng/privacy-policy',
                                          ),
                                        ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading.value ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Create account',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: 'Login',
                                  style: const TextStyle(
                                    color: AppTheme.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.login,
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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
        color: const Color(0xFF4B5563),
      ),
    );
  }
}
