import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';

/// a text-based loader that animates dots from 1 to 6
/// e.g. Loading. -> Loading.. -> Loading... -> Loading.... -> Loading..... -> Loading......
class DotsLoader extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration interval;

  const DotsLoader({
    super.key,
    this.text = 'Loading',
    this.style,
    this.interval = const Duration(milliseconds: 300),
  });

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader> {
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 6) + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          '${widget.text}${'.' * _dotCount}',
          style:
              widget.style ??
              GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }
}
