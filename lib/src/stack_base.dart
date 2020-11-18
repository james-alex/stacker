import 'package:flutter/widgets.dart';

/// The base class for the [Stacker], [StackSwapper], and
/// [StackSwitcher] widgets.
abstract class StackBase extends StatefulWidget {
  const StackBase({
    Key key,
    @required this.transitionDuration,
    @required this.transitionTranslation,
    @required this.invertTranslations,
    @required this.transitionFirstChild,
    this.onSwitchStart,
    this.onSwitchComplete,
    this.textDirection,
  })  : assert(transitionDuration != null),
        assert(transitionTranslation != null),
        assert(invertTranslations != null),
        assert(transitionFirstChild != null),
        super(key: key);

  /// The duration of the transition when switching widgets.
  final Duration transitionDuration;

  /// The offset the widgets are translated to while fading in/out.
  final Offset transitionTranslation;

  /// If `true`, the widbeing transitioned in will be translated
  /// in the inverse direction of the widbeing transitioned out.
  /// If `false`, both translations will be in the same direction.
  final bool invertTranslations;

  /// If `true`, the initial child will be transitioned in, otherwise
  /// the children will only be transitioned when swapping them.
  final bool transitionFirstChild;

  /// A callback executed when the switch transition starts.
  final VoidCallback onSwitchStart;

  /// A callback executed when the switch transition has completed.
  final VoidCallback onSwitchComplete;

  /// The text direction with which to resolve [alignment].
  ///
  /// Defaults to the ambient [Directionality].
  ///
  /// Copied from `Stack`.
  final TextDirection textDirection;
}

/// The base class for the [Stacker] and [StackSwitcher] widgets.
abstract class StatefulStackBase extends StackBase {
  const StatefulStackBase({
    Key key,
    @required Duration transitionDuration,
    @required Offset transitionTranslation,
    @required bool invertTranslations,
    @required bool transitionFirstChild,
    VoidCallback onSwitchStart,
    VoidCallback onSwitchComplete,
    @required this.maintainSizes,
    @required bool maintainAnimations,
    @required bool maintainStates,
    TextDirection textDirection,
  })  : assert(transitionDuration != null),
        assert(transitionTranslation != null),
        assert(invertTranslations != null),
        assert(transitionFirstChild != null),
        assert(maintainSizes != null),
        assert(maintainAnimations != null),
        assert(maintainStates != null),
        maintainAnimations = maintainSizes ? true : maintainAnimations,
        maintainStates =
            maintainAnimations || maintainSizes ? true : maintainStates,
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

  /// Whether to maintain space for where the hidden widgets would be.
  ///
  /// Maintaining the size when the widget is not [visible] is not notably more
  /// expensive than just keeping animations running without maintaining the
  /// size, and may in some circumstances be slightly cheaper if the subtree is
  /// simple and the [visible] property is frequently toggled, since it avoids
  /// triggering a layout change when the [visible] property is toggled. If the
  /// [child] subtree is not trivial then it is significantly cheaper to not
  /// even keep the state (see [maintainState]).
  ///
  /// If this property is true, [Opacity] is used instead of [Offstage].
  ///
  /// Dynamically changing this value may cause the current state of the
  /// subtree to be lost (and a new instance of the subtree, with new [State]
  /// objects, to be immediately created if [visible] is true).
  ///
  /// Copied from `Visibility`.
  final bool maintainSizes;

  /// Whether to maintain animations within the [child] subtree when it is
  /// not [visible].
  ///
  /// Keeping animations active when the widget is not visible is even more
  /// expensive than only maintaining the state.
  ///
  /// One example when this might be useful is if the subtree is animating its
  /// layout in time with an [AnimationController], and the result of that
  /// layout is being used to influence some other logic. If this flag is false,
  /// then any [AnimationController]s hosted inside the [child] subtree will be
  /// muted while the [visible] flag is false.
  ///
  /// If this property is true, no [TickerMode] widget is used.
  ///
  /// If this property is false, then [maintainSize] must also be false.
  ///
  /// Dynamically changing this value may cause the current state of the
  /// subtree to be lost (and a new instance of the subtree, with new [State]
  /// objects, to be immediately created if [visible] is true).
  ///
  /// Copied from `Visibility`.
  final bool maintainAnimations;

  /// Whether to maintain the [State] objects of the [children] and their
  /// subtrees when they're not visible.
  ///
  /// Keeping the state of the subtree is potentially expensive (because it
  /// means all the objects are still in memory; their resources are not
  /// released). It should only be maintained if it cannot be recreated on
  /// demand. One example of when the state would be maintained is if the child
  /// subtree contains a [Navigator], since that widget maintains elaborate
  /// state that cannot be recreated on the fly.
  ///
  /// If this property is true, an [Offstage] widget is used to hide the child
  /// instead of replacing it with [replacement].
  ///
  /// Dynamically changing this value may cause the current state of the
  /// subtree to be lost (and a new instance of the subtree, with new [State]
  /// objects, to be immediately created if [visible] is true).
  ///
  /// Copied from `Visibility` with minor changes.
  final bool maintainStates;
}
