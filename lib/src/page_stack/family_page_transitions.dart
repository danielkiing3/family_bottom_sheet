import 'package:flutter/widgets.dart';

/// Builds the transition around one page of a [FamilyPageStack]
///
/// {@template family_bottom_sheet.page_transition_builder}
/// `animation` goes from 0 to 1 as the page is pushed, and back to 0 as it is
/// popped. `secondaryAnimation` goes from 0 to 1 as another page is pushed on
/// top of it, and back to 0 as that page is popped
///
/// Return the same widget shape on every call so the page keeps its state.
/// {@endtemplate}
typedef FamilyPageTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);

abstract final class FamilyPageTransitions {
  /// The incoming page fades in while the outgoing one fades out
  static FamilyPageTransitionBuilder fade() {
    return (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: FadeTransition(
          opacity: ReverseAnimation(secondaryAnimation),
          child: child,
        ),
      );
    };
  }

  /// Like [fade], with the incoming page also sliding in by [offset] of its
  /// own size, and the outgoing page sliding the opposite way.
  static FamilyPageTransitionBuilder fadeThrough({
    Offset offset = const Offset(0.08, 0),
  }) {
    final fadeTransition = fade();
    return (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: offset, end: Offset.zero),
        ),
        child: SlideTransition(
          position: secondaryAnimation.drive(
            Tween<Offset>(begin: Offset.zero, end: -offset),
          ),
          child: fadeTransition(context, animation, secondaryAnimation, child),
        ),
      );
    };
  }
}
