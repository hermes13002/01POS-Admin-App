import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/presentation/screens/main_navigation_screen.dart';
import '../providers/auth_provider.dart';

const List<String> _backgroundImages = [
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
];

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgIndex = useState(0);
    final isEmailMode = useState(true);
    final isLoading = useState(false);

    // cycle background images every 5 seconds
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (_) {
        bgIndex.value = (bgIndex.value + 1) % _backgroundImages.length;
      });
      return timer.cancel;
    }, []);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // animated background
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
          // content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: isEmailMode.value
                      ? _EmailCard(
                          key: const ValueKey('email'),
                          isLoading: isLoading,
                          onSwitchToPin: () => isEmailMode.value = false,
                        )
                      : _PinCard(
                          key: const ValueKey('pin'),
                          isLoading: isLoading,
                          onSwitchToEmail: () => isEmailMode.value = true,
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

// --------------------------------------------------------------------------
// email/password card
// --------------------------------------------------------------------------
class _EmailCard extends HookConsumerWidget {
  const _EmailCard({
    super.key,
    required this.isLoading,
    required this.onSwitchToPin,
  });

  final ValueNotifier<bool> isLoading;
  final VoidCallback onSwitchToPin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final obscure = useState(true);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      isLoading.value = true;
      final error = await ref
          .read(authProvider.notifier)
          .loginWithEmail(emailCtrl.text.trim(), passwordCtrl.text);
      isLoading.value = false;

      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (_) => false,
        );
      }
    }

    return _BaseCard(
      children: [
        _CardHeader(onSwitchMode: onSwitchToPin, switchLabel: 'PIN Login'),
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
                  hintText: 'Youremail@mail.com',
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
                    onPressed: () => obscure.value = !obscure.value,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.poppins(
                      color: AppTheme.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _LoginButton(onPressed: submit, isLoading: isLoading),
              const SizedBox(height: 12),
              _SwitchModeButton(
                label: 'Login with Passcode instead',
                onPressed: onSwitchToPin,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------------
// PIN card
// --------------------------------------------------------------------------
class _PinCard extends HookConsumerWidget {
  const _PinCard({
    super.key,
    required this.isLoading,
    required this.onSwitchToEmail,
  });

  final ValueNotifier<bool> isLoading;
  final VoidCallback onSwitchToEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinCtrl = useTextEditingController();
    final obscure = useState(true);

    void appendDigit(String digit) {
      if (pinCtrl.text.length >= 6) return;
      pinCtrl.text += digit;
    }

    void backspace() {
      if (pinCtrl.text.isEmpty) return;
      pinCtrl.text = pinCtrl.text.substring(0, pinCtrl.text.length - 1);
    }

    Future<void> submit() async {
      final pin = pinCtrl.text.trim();
      if (pin.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your passcode')),
        );
        return;
      }
      isLoading.value = true;
      final error = await ref.read(authProvider.notifier).loginWithPin(pin);
      isLoading.value = false;

      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (_) => false,
        );
      }
    }

    return _BaseCard(
      children: [
        _CardHeader(onSwitchMode: onSwitchToEmail, switchLabel: 'Email Login'),
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
        _FieldLabel('Passcode'),
        const SizedBox(height: 6),
        TextField(
          controller: pinCtrl,
          obscureText: obscure.value,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Enter your passcode',
            suffixIcon: IconButton(
              icon: Icon(
                obscure.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppTheme.grey500,
                size: 20,
              ),
              onPressed: () => obscure.value = !obscure.value,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // numpad
        _NumPad(onDigit: appendDigit, onBackspace: backspace),
        const SizedBox(height: 20),
        _LoginButton(onPressed: submit, isLoading: isLoading),
        const SizedBox(height: 12),
        _SwitchModeButton(
          label: 'Login with Email',
          onPressed: onSwitchToEmail,
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------------
// shared widgets
// --------------------------------------------------------------------------

class _BaseCard extends StatelessWidget {
  const _BaseCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: children,
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.onSwitchMode, required this.switchLabel});

  final VoidCallback onSwitchMode;
  final String switchLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        // qr/switch icon button
        InkWell(
          onTap: onSwitchMode,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 22,
              color: AppTheme.grey700,
            ),
          ),
        ),
      ],
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

class _SwitchModeButton extends StatelessWidget {
  const _SwitchModeButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
          side: BorderSide(color: AppTheme.errorColor.withOpacity(0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.errorColor,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// numpad
// --------------------------------------------------------------------------

class _NumPad extends StatelessWidget {
  const _NumPad({required this.onDigit, required this.onBackspace});

  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        ...digits.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((d) => _NumKey(label: d, onTap: () => onDigit(d)))
                  .toList(),
            ),
          ),
        ),
        // bottom row: 0 + backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72),
            _NumKey(label: '0', onTap: () => onDigit('0')),
            _BackspaceKey(onTap: onBackspace),
          ],
        ),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.grey100,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatelessWidget {
  const _BackspaceKey({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.errorColor.withOpacity(0.12),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          size: 22,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }
}
