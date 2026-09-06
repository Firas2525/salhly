import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  final String assetPath;

  const AnimatedLogo({super.key, required this.assetPath});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnim;
  late final AnimationController _gleamController;
  late final AnimationController _scaleController;
  Timer? _gleamTimer;
  bool _rotationStopped = false;
  final Duration _pauseDuration = const Duration(seconds: 6);

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _rotationAnim = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    _startRotationCycle();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _scaleController.repeat(reverse: true);

    _gleamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _gleamTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _gleamController
            .forward(from: 0)
            .then((_) => _gleamController.reverse());
      }
    });
  }

  void _startRotationCycle() async {
    if (!mounted) return;
    _rotationStopped = false;
    while (mounted && !_rotationStopped) {
      try {
        await _rotationController.forward(from: 0.0);
        if (mounted) {
          _gleamController
              .forward(from: 0)
              .then((_) => _gleamController.reverse());
        }
        await Future.delayed(_pauseDuration);
      } catch (_) {
        break;
      }
    }
  }

  @override
  void dispose() {
    _rotationStopped = true;
    _rotationController.stop();
    _rotationController.dispose();
    _scaleController.dispose();
    _gleamController.dispose();
    _gleamTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 100,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _scaleController,
          _gleamController,
        ]),
        builder: (context, child) {
          final gleamValue = _gleamController.value;
          return Transform.rotate(
            angle: _rotationAnim.value,
            child: Transform.scale(
              scale: 1.0 + (_scaleController.value - 0.5) * 0.04,
              child: Stack(
                children: [
                  Positioned.fill(child: child!),
                  if (gleamValue > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: (math.sin(gleamValue * math.pi) * 0.9).clamp(
                            0.0,
                            0.95,
                          ),
                          child: ShaderMask(
                            blendMode: BlendMode.lighten,
                            shaderCallback: (rect) {
                              final start = -0.6 + gleamValue * 2.2;
                              return LinearGradient(
                                begin: Alignment(start, -0.3),
                                end: Alignment(start + 0.5, 0.3),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.9),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ).createShader(rect);
                            },
                            child: Container(
                              color: Colors.white.withOpacity(0.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(widget.assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
