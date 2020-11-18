/// A collection of 3 widgets that stack their children, displaying a
/// single child at a time, transitioning between children when a different
/// child is displayed.
///
/// Stacker can be used modularly as a component, to drive single-page apps,
/// or to control multi-step flows within a widget or page.
library stacker;

export 'src/helpers/maintain_state.dart';
export 'src/stack_swapper.dart';
export 'src/stack_switcher.dart';
export 'src/stacker.dart';
