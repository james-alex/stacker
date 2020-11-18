import 'package:flutter/widgets.dart';
import '../stacker.dart';

/// A widget whose [child]'s state will be maintained when hidden in a
/// [Stacker]/[StackSwitcher], even if their `maintainStates` parameter
/// is `false`.
class MaintainState extends StatelessWidget {
  /// A widget whose [child]'s state will be maintained when hidden in a
  /// [Stacker]/[StackSwitcher], even if their `maintainStates` parameter
  /// is `false`.
  ///
  /// [child] must not be `null`.
  ///
  /// If [maintainAnimation] is `true`, the states of any animations in
  /// the [child]'s subtree will be maintained when the widget is hidden.
  ///
  /// If [maintainSize] is `true`, the space the [child] would fill if it
  /// were visible will be maintained when the widget is hidden.
  /// [maintainAnimation] will automatically be set to `true` if [maintainSize]
  /// is `true`.
  const MaintainState(
    this.child, {
    bool maintainAnimation = false,
    this.maintainSize = false,
  })  : maintainAnimation = maintainSize ? true : maintainSize,
        assert(child != null);

  /// The widget being displayed in the [Stacker].
  final Widget child;

  /// Whether to maintain the states of any animations in the [child]'s subtree.
  final bool maintainAnimation;

  /// Whether the maintain the space the [child] would fill if it were visibile
  /// when it's hidden.
  final bool maintainSize;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
