import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// a shared widget that cycles through background images every 5 seconds
class AnimatedBackground extends HookWidget {
  final List<String> images;
  final Duration duration;
  final double overlayOpacity;

  const AnimatedBackground({
    super.key,
    required this.images,
    this.duration = const Duration(seconds: 5),
    this.overlayOpacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox();

    final bgIndex = useState(0);

    // cycle background images
    useEffect(() {
      final timer = Timer.periodic(duration, (_) {
        bgIndex.value = (bgIndex.value + 1) % images.length;
      });
      return timer.cancel;
    }, [images, duration]);

    return Stack(
      fit: StackFit.expand,
      children: [
        // cycling image
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: Image.network(
            images[bgIndex.value],
            key: ValueKey(images[bgIndex.value]),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(color: Colors.black87),
          ),
        ),
        // subtle dark overlay for readability
        Container(color: Colors.black.withValues(alpha: overlayOpacity)),
      ],
    );
  }
}
