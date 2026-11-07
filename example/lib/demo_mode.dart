import 'package:flutter/material.dart';

/// On when the demo recordings run (`--dart-define=DEMO_MODE=true`): the debug
/// banner is hidden and touches are drawn, since scripted taps show no finger.
const bool kDemoMode = bool.fromEnvironment('DEMO_MODE');

/// Draws a dot under every finger touching [child].
class DemoTouches extends StatefulWidget {
  const DemoTouches({super.key, required this.child});

  final Widget child;

  @override
  State<DemoTouches> createState() => _DemoTouchesState();
}

class _DemoTouchesState extends State<DemoTouches> {
  final Map<int, Offset> _touches = {};

  void _track(PointerEvent event) =>
      setState(() => _touches[event.pointer] = event.position);

  void _release(PointerEvent event) =>
      setState(() => _touches.remove(event.pointer));

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _track,
      onPointerMove: _track,
      onPointerUp: _release,
      onPointerCancel: _release,
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          widget.child,
          for (final position in _touches.values)
            Positioned(
              left: position.dx - 20,
              top: position.dy - 20,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 2,
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
