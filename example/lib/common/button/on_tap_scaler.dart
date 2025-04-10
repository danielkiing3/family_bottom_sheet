import 'package:flutter/material.dart';

class OnTapScaler extends StatefulWidget {
  const OnTapScaler({this.onTap, required this.child, super.key});

  final VoidCallback? onTap;

  final Widget child;

  @override
  State<OnTapScaler> createState() => _OnTapScalerState();
}

class _OnTapScalerState extends State<OnTapScaler>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 125),
  );

  late final _curvedAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutSine,
    reverseCurve: Curves.easeOutSine.flipped,
  );

  late final _scale = Tween<double>(
    begin: 1,
    end: 0.95,
  ).animate(_curvedAnimation);

  @override
  void dispose() {
    _controller.dispose();
    _curvedAnimation.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) async {
        if (widget.onTap != null) {
          widget.onTap!();
        }

        if (!_controller.isCompleted) {
          await _controller.forward();
        }

        if (!mounted) return;

        await _controller.reverse();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: RepaintBoundary(
          child: ScaleTransition(scale: _scale, child: widget.child),
        ),
      ),
    );
  }
}
