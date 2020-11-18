import 'package:fade_and_translate/fade_and_translate.dart';
import 'package:flutter/widgets.dart';
import 'stack_base.dart';
import 'stack_switcher.dart';

/// A stack that displays a single widget implicitly transitions
/// to displaying a new child when its child is updated.
class StackSwapper extends StackBase {
  /// A stack that displays a single widget implicitly transitions
  /// to displaying a new child when its child is updated.
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
  /// [textDirection] is required when no ancestor provides a [Directionality]
  /// widget. Typically the [Directionality] widget is introduced by the
  /// [MaterialApp] or [WidgetsApp] at the top of your application widget tree.
  ///
  /// __Note:__ Any children whose parameters or states are modified will
  /// be detected as a new child, triggering the transition. To prevent
  /// this from happening, set the child's [key], or consider using a
  /// [StackSwitcher] instead.
  StackSwapper(
    this.child, {
    Key key,
    Duration transitionDuration = const Duration(milliseconds: 240),
    Offset transitionTranslation = const Offset(0.0, -24.0),
    bool invertTranslations = true,
    bool transitionFirstChild = false,
    VoidCallback onSwitchStart,
    VoidCallback onSwitchComplete,
    TextDirection textDirection,
  })  : assert(child != null),
        assert(transitionDuration != null),
        assert(transitionTranslation != null),
        assert(invertTranslations != null),
        assert(transitionFirstChild != null),
        super(
          key: key,
          transitionDuration: transitionDuration,
          transitionTranslation: transitionTranslation,
          invertTranslations: invertTranslations,
          transitionFirstChild: transitionFirstChild,
          onSwitchStart: onSwitchStart,
          onSwitchComplete: onSwitchComplete,
          textDirection: textDirection,
        );

  /// The child currently being displayed.
  final Widget child;

  @override
  _StackSwapperState createState() => _StackSwapperState();
}

class _StackSwapperState extends State<StackSwapper> {
  /// Whether [_front] or [_back] is the visible widget.
  bool _toggled = false;

  /// The first widget being displayed.
  ///
  /// Transitions in when [_back] transitions out and vice versa.
  Widget _front;

  /// The second widget being displayed.
  ///
  /// Transitions in when [_front] transitions out and vice versa.
  Widget _back;

  @override
  void initState() {
    super.initState();
    _front = widget.child;
  }

  @override
  void didUpdateWidget(StackSwapper old) {
    if (widget.child != old.child) {
      toggle(widget.child);
    }

    super.didUpdateWidget(old);
  }

  /// Toggles the transition between widgets, hiding the widget
  /// currently being displayed and revealing [child].
  void toggle(Widget child) {
    if (_toggled) {
      _front = child;
    } else {
      _back = child;
    }

    _toggled = !_toggled;

    setState(() {});
  }

  /// Removes the last displayed child from the build tree,
  /// causing it to be replaced with an empty [Container].
  void clearLastChild() {
    if (_toggled) {
      _front = null;
    } else {
      _back = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: widget.textDirection,
      children: [
        // Foreground widget (not toggled)
        FadeAndTranslate(
          translate: widget.invertTranslations && _toggled
              ? widget.transitionTranslation * -1
              : widget.transitionTranslation,
          autoStart: widget.transitionFirstChild,
          duration: widget.transitionDuration,
          visible: !_toggled,
          child: _front ?? Container(),
        ),
        // Background widget (toggled)
        FadeAndTranslate(
          translate: widget.invertTranslations && _toggled
              ? widget.transitionTranslation * -1
              : widget.transitionTranslation,
          duration: widget.transitionDuration,
          visible: _toggled,
          onComplete: clearLastChild,
          child: _back ?? Container(),
        ),
      ],
    );
  }
}
