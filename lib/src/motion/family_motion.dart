import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// How something in the package moves: a spring, or a fixed-length curve.
///
/// ```dart
/// motion: const FamilyMotion.spring(duration: Duration(milliseconds: 350)),
/// motion: const FamilyMotion.curved(Duration(milliseconds: 200)),
/// ```
sealed class FamilyMotion {
  const FamilyMotion();

  /// A spring described the way iOS describes them. [duration] is roughly how
  /// long it takes to settle, and [bounce] how much it overshoots: 0 for none,
  /// up to 1. Overshoot is clipped where the value can't go past its end, e.g.
  /// a sheet can't rise above fully open.
  const factory FamilyMotion.spring({Duration duration, double bounce}) =
      SpringFamilyMotion;

  /// A fixed-length animation along [curve]
  const factory FamilyMotion.curved(
    Duration duration, {
    Curve curve,
    Duration? reverseDuration,
  }) = CurvedFamilyMotion;

  Simulation simulate({
    required double from,
    required double to,
    double velocity = 0,
  });
}

class SpringFamilyMotion extends FamilyMotion {
  const SpringFamilyMotion({
    this.duration = const Duration(milliseconds: 400),
    this.bounce = 0,
  }) : assert(bounce >= 0 && bounce <= 1);

  final Duration duration;
  final double bounce;

  @override
  Simulation simulate({
    required double from,
    required double to,
    double velocity = 0,
  }) {
    return SpringSimulation(
      SpringDescription.withDurationAndBounce(
        duration: duration,
        bounce: bounce,
      ),
      from,
      to,
      velocity,
      snapToEnd: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SpringFamilyMotion &&
      other.duration == duration &&
      other.bounce == bounce;

  @override
  int get hashCode => Object.hash(duration, bounce);
}

class CurvedFamilyMotion extends FamilyMotion {
  const CurvedFamilyMotion(
    this.duration, {
    this.curve = Curves.easeInOut,
    this.reverseDuration,
  });

  final Duration duration;
  final Curve curve;
  final Duration? reverseDuration;

  @override
  Simulation simulate({
    required double from,
    required double to,
    double velocity = 0,
  }) {
    final full = to < from ? reverseDuration ?? duration : duration;
    return _CurveSimulation(
      from: from,
      to: to,
      curve: curve,
      seconds: full.inMicroseconds /
          Duration.microsecondsPerSecond *
          (to - from).abs(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CurvedFamilyMotion &&
      other.duration == duration &&
      other.curve == curve &&
      other.reverseDuration == reverseDuration;

  @override
  int get hashCode => Object.hash(duration, curve, reverseDuration);
}

class _CurveSimulation extends Simulation {
  _CurveSimulation({
    required this.from,
    required this.to,
    required this.curve,
    required this.seconds,
  });

  final double from;
  final double to;
  final Curve curve;
  final double seconds;

  double _progress(double time) =>
      seconds <= 0 ? 1 : (time / seconds).clamp(0.0, 1.0);

  @override
  double x(double time) =>
      from + (to - from) * curve.transform(_progress(time));

  @override
  double dx(double time) {
    const step = 1 / 120;
    return (x(time + step) - x(time)) / step;
  }

  @override
  bool isDone(double time) => time >= seconds;
}

extension FamilyMotionController on AnimationController {
  /// Moves to [target] with [motion], keeping [velocity] if it's a spring.
  /// Moving down reports a reverse status, so routes and pages see a pop.
  TickerFuture animateWithMotion(
    FamilyMotion motion, {
    required double target,
    double velocity = 0,
  }) {
    final simulation = motion.simulate(
      from: value,
      to: target,
      velocity: velocity,
    );
    return target < value
        ? animateBackWith(simulation)
        : animateWith(simulation);
  }
}
