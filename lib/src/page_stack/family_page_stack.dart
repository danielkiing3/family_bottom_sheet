import 'dart:async';

import 'package:flutter/widgets.dart';

import '../motion/family_motion.dart';
import 'family_page_transitions.dart';
import 'page_stack_layout.dart';

const FamilyMotion _defaultMotion = FamilyMotion.spring(
  duration: Duration(milliseconds: 350),
);

/// A stack of page that keeps every widget alive while it is in the stack,
/// animate between them, and resizes itself to the page on top
///
/// It does not own the visual, so it's use is agnostic, it can live inside a
/// bottomsheet, dialog or any other container
///
/// Page below the top one stay mounted, so their state is still there when
/// you pop back to them. They don't paint, tick, take focus or receive pointer
/// events while they are covered
///
/// The system back gesture pops a page first, and only lets the enclosing
/// route pop once a single page is left.
class FamilyPageStack extends StatefulWidget {
  const FamilyPageStack({
    super.key,
    required this.initialPage,
    this.transitionBuilder,
    this.motion,
    this.canUserPop,
    this.alignment = Alignment.topCenter,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The first page. Popping past it pops the enclosing route
  final Widget initialPage;

  /// Builds the transition for each page.
  ///
  /// {@macro family_bottom_sheet.page_transition_builder}
  ///
  /// Defaults to [FamilyPageTransitions.fade].
  final FamilyPageTransitionBuilder? transitionBuilder;

  /// How pages move into each other, and the size change between them.
  /// Defaults to a 350ms spring with no bounce.
  final FamilyMotion? motion;

  /// Whether the system back gesture may pop a page right now. Read each time
  /// back is used. When it returns false, back does nothing.
  final ValueGetter<bool>? canUserPop;

  /// Where a page sits when it is smaller than the stack mid-transition.
  final AlignmentGeometry alignment;

  /// How to clip a page that is larger than the stack mid-transition.
  final Clip clipBehavior;

  /// The nearest [FamilyPageStackState] above [context].
  static FamilyPageStackState of(BuildContext context) {
    final state = maybeOf(context);
    assert(() {
      if (state == null) {
        throw FlutterError.fromParts([
          ErrorSummary('FamilyPageStack.of() called with no FamilyPageStack '
              'in the context.'),
          ErrorHint('Call it from a widget inside a page shown with '
              'FamilyModalSheet, or inside your own FamilyPageStack.'),
        ]);
      }
      return true;
    }());
    return state!;
  }

  /// The nearest [FamilyPageStackState] above [context], if any.
  static FamilyPageStackState? maybeOf(BuildContext context) {
    if (context is StatefulElement && context.state is FamilyPageStackState) {
      return context.state as FamilyPageStackState;
    }
    return context.findAncestorStateOfType<FamilyPageStackState>();
  }

  @override
  State<FamilyPageStack> createState() => FamilyPageStackState();
}

class FamilyPageStackState extends State<FamilyPageStack>
    with TickerProviderStateMixin {
  final List<_PageEntry> _entries = [];
  late _PageEntry _initialEntry;

  Iterable<_PageEntry> get _activeEntries =>
      _entries.where((entry) => !entry.isLeaving);

  FamilyMotion get _motion => widget.motion ?? _defaultMotion;

  /// Whether [popPage] will pop a page rather than the enclosing route.
  bool get canPopPage => _activeEntries.length > 1;

  /// The number of pages in the stack.
  int get pageCount => _activeEntries.length;

  /// Pushes [page] on top of the stack.
  ///
  /// The returned future completes with the result passed to [popPage] when
  /// this page is popped.
  Future<R?> pushPage<R extends Object?>(Widget page) {
    _removeLeavingEntries();
    final entry = _PageEntry(page: page, controller: _createController(0));
    setState(() => _entries.add(entry));
    entry.controller.animateWithMotion(_motion, target: 1);
    return entry.result.future.then((value) => value as R?);
  }

  /// Replaces the top page with [page]
  ///
  /// The replaced page's [pushPage] future completes with [result]. The
  /// returned future completes when [page] is popped.
  Future<R?> replacePage<R extends Object?>(Widget page, {Object? result}) {
    _removeLeavingEntries();
    final replaced = _activeEntries.last..isLeaving = true;
    replaced.result.complete(result);
    final entry = _PageEntry(page: page, controller: _createController(0));
    setState(() => _entries.add(entry));
    entry.controller
        .animateWithMotion(_motion, target: 1)
        .whenCompleteOrCancel(() {
      if (mounted && _entries.contains(replaced)) {
        setState(() => _removeEntry(replaced));
      }
    });
    return entry.result.future.then((value) => value as R?);
  }

  /// Pops the top page, completing its [pushPage] future with [result].
  ///
  /// With a single page left, pops the enclosing route instead.
  void popPage<R extends Object?>([R? result]) {
    final active = _activeEntries.toList();
    if (active.length <= 1) {
      Navigator.of(context).pop(result);
      return;
    }
    _popTop(active.last, result);
  }

  /// Pops every page above the first, animating straight from the top page
  /// to the first one. Their [pushPage] futures complete with null.
  void popToFirstPage() {
    final active = _activeEntries.toList();
    if (active.length <= 1) return;

    _removeLeavingEntries();
    for (final entry in active.sublist(1, active.length - 1)) {
      entry.result.complete();
      _removeEntry(entry);
    }
    _popTop(active.last, null);
  }

  void _popTop(_PageEntry entry, Object? result) {
    entry
      ..isLeaving = true
      ..result.complete(result);
    setState(() {});
    entry.controller
        .animateWithMotion(_motion, target: 0)
        .whenCompleteOrCancel(() {
      if (mounted && _entries.contains(entry)) {
        setState(() => _removeEntry(entry));
      }
    });
  }

  AnimationController _createController(double value) {
    return AnimationController(vsync: this, value: value)..addListener(_onTick);
  }

  void _onTick() => setState(() {});

  void _removeLeavingEntries() {
    for (final entry in _entries.where((e) => e.isLeaving).toList()) {
      _removeEntry(entry);
    }
  }

  void _removeEntry(_PageEntry entry) {
    _entries.remove(entry);
    entry.controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initialEntry = _PageEntry(
      page: widget.initialPage,
      controller: _createController(1),
    );
    _entries.add(_initialEntry);
  }

  @override
  void didUpdateWidget(FamilyPageStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPage != widget.initialPage) {
      _initialEntry.page = widget.initialPage;
    }
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = _entries.length;
    final interactive = _activeEntries.last;
    final transitionBuilder =
        widget.transitionBuilder ?? FamilyPageTransitions.fade();

    // A page is drawn while everything above it is still partly transparent.
    final visible = List<bool>.filled(count, false)..[count - 1] = true;
    for (var i = count - 1; i > 0; i--) {
      if (_entries[i].controller.value >= 1) break;
      visible[i - 1] = true;
    }

    final top = _entries.last;
    final sizeProgress = count > 1 ? top.controller.value : 1.0;

    return PopScope(
      canPop: !canPopPage,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && (widget.canUserPop?.call() ?? true)) popPage();
      },
      child: PageStackLayout(
        fromIndex: count > 1 ? count - 2 : count - 1,
        toIndex: count - 1,
        progress: sizeProgress,
        alignment: widget.alignment,
        clipBehavior: widget.clipBehavior,
        children: [
          for (var i = 0; i < count; i++)
            PageStackSlot(
              key: _entries[i].key,
              visible: visible[i],
              child: TickerMode(
                enabled: visible[i],
                child: ExcludeFocus(
                  excluding: _entries[i] != interactive,
                  child: ExcludeSemantics(
                    excluding: _entries[i] != interactive,
                    child: IgnorePointer(
                      ignoring: _entries[i] != interactive,
                      child: transitionBuilder(
                        context,
                        _entries[i].controller,
                        i + 1 < count
                            ? _entries[i + 1].controller
                            : kAlwaysDismissedAnimation,
                        _entries[i].page,
                      ),
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

class _PageEntry {
  _PageEntry({required this.page, required this.controller});

  Widget page;
  final AnimationController controller;
  final Completer<Object?> result = Completer<Object?>();
  final Key key = UniqueKey();
  bool isLeaving = false;
}
