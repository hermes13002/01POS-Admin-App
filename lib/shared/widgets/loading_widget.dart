import 'package:flutter/material.dart';

/// Loading widget with animated logo
class LoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({super.key, this.message, this.color, this.size = 65});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduced padding shrinks the overall container size
    const double containerPadding = 8.0;
    final double innerCircleSize = widget.size + (containerPadding * 2);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glowing sweep gradient
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.1415927,
                    child: Container(
                      width: innerCircleSize + 4, // Sleek 2px spinning border
                      height: innerCircleSize + 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            widget.color ??
                                Theme.of(context).colorScheme.primary,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Inner solid circle with logo (shadow removed per request)
              Container(
                width: innerCircleSize,
                height: innerCircleSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 246, 246, 246),
                ),
                padding: const EdgeInsets.all(containerPadding),
                child: Image.asset(
                  'assets/images/logo/logo-single.png',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.store,
                      size: widget.size,
                      color:
                          widget.color ?? Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
              ),
            ],
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 32),
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
