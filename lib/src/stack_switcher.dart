import 'package:fade_and_translate/fade_and_translate.dart';
import 'package:flutter/widgets.dart';
import 'helpers/maintain_state.dart';
import 'stack_base.dart';

/// An interface for navigating a [Stack] which displays one widget
/// at a time, implicitly transitioning between children when the
/// index of the [child] to display is changed.
class StackSwitcher extends StatefulStackBase {
  /// An interface for navigating a [Stack] which displays one widget
  /// at a time, implicitly transitioning between children when the
  /// index of the [child] to display is changed.
  ///
  /// [children] contains all of the widgets that can be displayed.
  /// At least one child must be contained in [children].
  ///
  /// [child] is the index of the widget within [children] that's
  /// currently being displayed. When [child] is changed, the widget
  /// that was being displayed with implicitly transition to the
  /// widget at [child]. [child] must be a valid index.
  ///
  /// The animated transition when switching widgets is handled by a
  /// [FadeAndTranslate]. [transitionDuration] sets the duration of the
  /// transition, and [transitionTranslation] sets the offset the widgets
  /// are translated during the transition.
  ///
  /// If [invertTranslations] is `true`, the widget being transitioned in will
  /// be translated in the inverse direction of the widget being transitioned
  /// out. If `false`, both translations will in the same direction.
  ///
  /// If [transitionFirstChild] is `true`, the first child to be displayed will
  /// be built in a hidden state and transition into view.
  ///
  /// [onSwitchStart] and [onSwitchComplete] are callbacks exectued when the
  /// switch transition starts and ends, respectively.
  ///
  /// If [maintainSizes] is `true`, the space of the where the hidden widgets
  /// are will be maintained when the widgets are hidden. [maintainStates]
  /// and [maintainAnimations] will automatically be set to `true` if
  /// [maintainSizes] is `true`.
  ///
  /// If [maintainAnimations] is `true`, the states of animations within the
  /// widgets' subtrees will be maintained when they're hidden. [maintainStates]
  /// will automatically be set to `true` if [maintainAnimations] is `true`.
  ///
  /// If [maintainStates] is `true`, the states of the widgets will be maintained
  /// when the widgets are hidden. If `false`, they will be built new each time
  /// they become visible.
  ///
  /// __Note:__ [maintainSizes], [maintainAnimations] and [maintainState] are
  /// potentially expensive operations, avoid using them if possible. Consider
  /// using a [MaintainState] widget to wrap only the widgets whose states,
  /// animations, and sizes need to be maintained instead.
  ///
  /// [textDirection] is required when no ancestor provides a [Directionality]
  /// widget. Typically the [Directionality] widget is introduced by the
  /// [MaterialApp] or [WidgetsApp] at the top of your application widget tree.
  StackSwitcher(
    this.children, {
    Key key,
    @required this.child,
    Duration transitionDuration = const Duration(milliseconds: 240),
    Offset transitionTranslation = const Offset(0.0, 24.0),
    bool invertTranslations = true,
    bool transitionFirstChild = false,
    VoidCallback onSwitchStart,
    VoidCallback onSwitchComplete,
    bool maintainSizes = false,
    bool maintainAnimations = false,
    bool maintainStates = false,
    TextDirection textDirection,
  })  : assert(children != null && children.isNotEmpty),
        assert(child != null && child >= 0 && child < children.length),
        assert(transitionDuration != null),
        assert(transitionTranslation != null),
        assert(invertTranslations != null),
        assert(transitionFirstChild != null),
        assert(maintainSizes != null),
        assert(
            !maintainSizes || (maintainStates && maintainAnimations),
            '[maintainStates] and [maintainAnimations] both must be set to '
            '`true` for [maintainSizes] to be used.'),
        assert(maintainAnimations != null),
        assert(
            !maintainAnimations || maintainStates,
            '[maintainStates] must be set to `true` for [maintainAnimations]'
            'to be used.'),
        assert(maintainStates != null),
        super(
          key: key,
          transitionDuration: transitionDuration,
          transitionTranslation: transitionTranslation,
          invertTranslations: invertTranslations,
          transitionFirstChild: transitionFirstChild,
          onSwitchStart: onSwitchStart,
          onSwitchComplete: onSwitchComplete,
          maintainSizes: maintainSizes,
          maintainAnimations: maintainAnimations,
          maintainStates: maintainStates,
          textDirection: textDirection,
        );

  /// The children in the stack. Only one child is displayed
  /// at a time, at the index specified by [child].
  final List<Widget> children;

  /// The index of the widget in [children] currently being displayed.
  final int child;

  @override
  _StackSwitcherState createState() => _StackSwitcherState();
}

class _StackSwitcherState extends State<StackSwitcher> {
  /// The keys assigned to the [FadeAndTranslate] widget that
  /// wraps each child.
  final List<GlobalKey> _keys = <GlobalKey>[];

  /// The list of children that can be displayed in the stack.
  List<Widget> _children;

  /// `true` if the widget hasn't been built yet and
  /// [widget.transitionFirstChild] is `true`.
  ///
  /// Used to determine if the initially displayed child's [FadeAndTranslate]'s
  /// `autoStart` parameter should be set to `true`.
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _buildChildren();
  }

  @override
  void didUpdateWidget(StackSwitcher old) {
    if (widget.child != old.child) {
      _buildChildren();
    }

    super.didUpdateWidget(old);
  }

  /// Builds all of the [children] by wrapping them in a [FadeAndTranslate]
  /// widget and setting their visibility and other parameters accordingly.
  void _buildChildren() {
    if (_keys.length != widget.children.length) {
      _setKeys();
    }

    _children = List<Widget>.generate(widget.children.length, (index) {
      final child = widget.children[index];
      final isVisible = widget.child == index;
      final maintainState = widget.maintainStates || child is MaintainState;
      final maintainAnimation = widget.maintainAnimations ||
          (child is MaintainState && child.maintainAnimation);
      final maintainSize = widget.maintainSizes ||
          (child is MaintainState && child.maintainSize);
      final onStart = () {
        if (isVisible && widget.onSwitchStart != null) {
          widget.onSwitchStart();
        }
      };
      final onComplete = () {
        if (isVisible && widget.onSwitchComplete != null) {
          widget.onSwitchComplete();
        }
      };

      return FadeAndTranslate(
        key: _keys[index],
        visible: isVisible,
        duration: widget.transitionDuration,
        translate: !widget.invertTranslations && widget.child == index
            ? widget.transitionTranslation * -1
            : widget.transitionTranslation,
        autoStart: (_isFirstBuild && widget.transitionFirstChild) ||
            (!_isFirstBuild && isVisible),
        maintainState: maintainState,
        maintainAnimation: maintainAnimation,
        maintainSize: maintainSize,
        onStart: onStart,
        onComplete: onComplete,
        child: child,
      );
    });

    if (_isFirstBuild) _isFirstBuild = false;

    if (mounted) setState(() {});
  }

  /// Creates/removes [GlobalKey]s to/from [_keys]
  /// until there is one key for every child.
  void _setKeys() {
    while (_keys.length != widget.children.length) {
      if (_keys.length > widget.children.length) {
        _keys.removeLast();
      } else {
        _keys.add(GlobalKey());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: widget.textDirection,
      children: _children,
    );
  }
}
