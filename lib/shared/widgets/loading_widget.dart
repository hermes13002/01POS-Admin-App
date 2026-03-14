import 'package:flutter/material.dart';

/// Loading widget with animated logo
class LoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 65,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 246, 246, 246),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.18),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/logo/logo-single.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.store,
                    size: widget.size,
                    color: widget.color ?? Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
