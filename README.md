# stacker

A collection of 3 widgets that stack their children, displaying a
single child at a time, transitioning between children when a different
child is displayed.

Stacker can be used modularly as a component, to drive single-page apps,
or to control multi-step flows within a widget or page.

# Usage

```dart
import 'package:stacker/stacker.dart';
```

## StackSwapper

[StackSwapper] is the simplest of the three widgets. It accepts a single
child and implicity transitions to displaying a new child when its child
is updated.

```dart
/// The child being displayed by the [StackSwapper].
var child = Container(child: Text('A'));

/// Transitions [StackSwapper] to displaying a different widget.
void updateChild() {
  child = Container(child: Text('B'));
  setState(() {});
}

/// Build the [StackSwapper].
@override
Widget build(BuildContext context) {
  return StackSwapper(child);
}
```

## StackSwitcher

[StackSwitcher] accepts a list of children and the index of the child
that should be displayed. When the index is changed it will transition
to displaying the child at the new index.

```dart
/// The children contained in [StackSwitcher]'s stack.
final children = <Widget>[
  Container(child: Text('A')),
  Container(child: Text('B')),
  Container(child: Text('C')),
  Container(child: Text('D')),
  Container(child: Text('E')),
];

/// The index of the child in [children] currently being
/// dispalyed by the [StackSwitcher].
var currentChild = 0;

/// Transitions [StackSwitcher] to displaying the next child in the list.
void nextChild() {
  currentChild = (currentChild + 1) % children.length;
  setState(() {});
}

/// Build the [StackSwitcher].
@override
Widget build(BuildContext context) {
  return StackSwitcher(children, child: currentChild);
}
```

### Maintaining States

The states of every child in the stack can be maintained when they're
not visible by setting the [maintainStates], [maintainAnimations], or
[maintainSizes] parameters to `true`.

[maintainStates] will maintain the state of the child.

[maintainAnimations] will keep the animation ticker providers active
while the children are hidden. Setting this to `true` will automatically
set [maintainStates] to `true`.

[maintainSizes] will maintain the space the hidden children would occupy
if they were visible. Setting this to `true` will automatically set
[maintainAnimations] and [maintainStates] to `true`.

```dart
/// A [StackSwitcher] where every child's state will
/// be maintained when they're hidden.
StackSwitcher(
  children,
  child: currentChild,
  maintainStates: true,
);
```

An individual child's state/animation/size can be maintained by wrapping the
child in a [MaintainState] widget.

[MaintainState] has 2 parameters, [maintainAnimation] and [maintainSize].
Setting [maintainSize] to `true` will automatically set [maintainAnimation]
to `true`.

```dart
/// A list of children whose states will be maintained, or not,
/// independently of one another.
final children = <Widget>[
  // The state of this widget will be maintained when it is hidden.
  MaintainState(MyStatefulWidget())),

  // The state of this child will not be maintained when it is hidden.
  MyStatefulWidget(),

  // The state and animation tickers of this widget will be
  // maintained when it is hidden.
  MaintainState(
    MyStatefulWidget(),
    maintainAnimation: true,
  ),

  // The state of this child will not be maintained when it is hidden.
  MyStatefulWidget(),

  // The state, animation tickers, and size of this widget will be
  // maintained when it is hidden.
  MaintainState(
    MyStatefulWidget(),
    maintainSize: true,
  ),
];
```

## Stacker

[Stacker] accepts a single child, which acts as the root of a linear
history of widgets, which can be navigated (like a browser's back and
forward buttons.)

New children can be built, inserted into, or removed from the stack on
the fly.

There a number of direct methods for controlling and navigating
the stack, which are accessed from the [Stacker]'s instance.

All of [Stacker]'s navigation/build methods have an optional [onComplete]
parameter, which can be used to provide a callback that will be called a
single time when the transition triggered by that method completes.

```dart
/// An instance of a [Stacker]. By storing the [Stacker] as an instance,
/// its direct methods can be used to control it.
final myStacker = Stacker(MyRootWidget());

/// Builds and transitions to a new [child].
void build(Widget child, {VoidCallback onComplete}) {
  myStacker.build(child, onComplete: onComplete);
}

/// Transitions to the child before the child currently being displayed.
void back({VoidCallback onComplete}) {
  myStacker.back(onComplete: onComplete);
}

/// Transitions to the child after the child currently being displayed.
void forward({VoidCallback onComplete}) {
  myStacker.forward(onComplete: onComplete);
}

/// Transitions to the child at [index].
void open(int index, {VoidCallback onComplete}) {
  myStacker.open(index, onComplete: onComplete);
}

/// Transitions to the child before the child currently being displayed,
/// and removing the current child and every child after it from the history.
void pop({VoidCallback onComplete}) {
  myStacker.pop(onComplete: onComplete);
}

/// Transitions to the root child.
void root({VoidCallback onComplete}) {
  myStacker.root(onComplete: onComplete);
}
```

Those same methods are also accessible from any of the [Stacker]'s
children via a [BuildContext] extension by calling [context] within
a [StatelessWidget]'s [build] method, or anywhere within a [State].
__Note:__ These have the same optional parameters as their respective
equivalent methods listed above and in the section below.

```dart
// Builds and transitions to a new child.
context.stacker.build(child);

// Transitions to the previous child.
context.stacker.back();

// Transitions to the next child.
context.stacker.forward();

// Transitions to the child at [index].
context.stacker.open(index);

// Transitions the previous child and clears the history.
context.stacker.pop();

// Transitions to the root child.
context.stacker.root();
```

__Note:__ If a [Stacker] is built directly by its parent's [build] method,
only its children will be able to access the methods to control the stacker,
which may be all you need depending on the use-case.

```dart
/// The [Stacker] built here can only be controlled by
/// [MyRootWidget] or any other children added to it.
@override
Widget build(BuildContext context) {
  return Stacker(MyRootWidget());
}
```

### Managing the History

The history can be cleared by calling [clearHistory]. The history is also
cleared when building or appending a widget to the history, unless the [build]
or [append] methods' [clearHistory] parameter is changed to `false`, or when
navigating to the root child by setting the [clearHistory] parameter to `true`.

```dart
/// Builds and transitions to a new [child], clearing the history
/// by default.
///
/// If [clearHistory] is set to `false`, every child in the forward
/// history will be pushed back when the new [child] is built.
void build(Widget child, {bool clearHistory = true}) {
  myStacker.build(child, clearHistory: clearHistory);
}

/// Transitions to the root widget in the stack, clearing the history
/// if [clearHistory] is set to `true`.
void root({bool clearHistory = false}) {
  myStacker.root(clearHistory: clearHistory);
}
```

Children can be inserted into or removed from the history by any of
the below methods.

```dart
/// Inserts a [child] into the stack before the one currently
/// being displayed.
void prepend(Widget child) {
  myStacker.prepend(child);
}

/// Inserts a [child] into the stack after the one currently
/// being displayed, clearing the history by default.
void append(Widget child, {bool clearHistory = true}) {
  myStacker.append(child, clearHistory: clearHistory);
}

/// Inserts a [child] into the stack at [index], pushing
/// every child occuring on or after [index] back.
void insert(int index, Widget child) {
  myStacker.insert(index, child);
}

/// Removes the first instance of [child] from the stack.
void remove(Widget child) {
  myStacker.remove(child);
}

/// Removes the child from the stack at [index].
void removeAt(int index) {
  myStacker.removeAt(index);
}

/// Removes every widget from stack after the one currently
/// being diplayed, clearing the forward history.
///
/// If [skip] is `> 0`, that number of widgets after the one currently
/// being displayed will be retained in the history.
void clearHistory([int skip = 0]) {
  myStacker.clearHistory(skip);
}
```

All of the above methods are also accessible to a [Stacker]'s children
via the [BuildContext] extension. __Note:__ These methods have the same
optional parameters as their respective equivalents listed above.

```dart
// Inserts a child into the stack before the one currently
// being displayed.
context.stacker.prepend(child);

// Inserts a child into the stack after the one currently
// being displayed, clearing the history by default.
context.stacker.append(child);

// Inserts a [child] into the stack at [index], pushing
// every child occuring on or after [index] back.
context.stacker.insert(index, child);

// Removes the first instance of [child] from the stack.
context.stacker.remove(child);

// Removes the child from the stack at [index].
context.stacker.removeAt(index);

// Removes every widget from stack after the one currently
// being diplayed
context.stacker.clearHistory();
```

### Android Back Button

The [backButton] parameter can be set to `true` to have the [Stacker]
intercept the Android back button and navigate backwards in the [Stacker]'s
history when it's pressed.

```dart
/// This [Stacker] can be navigated with Android's back button.
Stacker(
  MyRootWidget(),
  backButton: true,
);
```

If the root child is being displayed, the back button will defer to the
default behavior.

### Maintaining States

A [Stacker]'s childrens' states can be maintained in the same way as a
[StackSwitcher]s', either by setting the [maintainStates], [maintainAnimations],
or [maintainSizes] parameters to `true`, or by wrapping individual children
in a [MaintainState] widget.

# Parameters

Each of the widgets have a number of shared parameters used to provide
callbacks or to customize their transition animation.

## Transitions

The transitions between children are handled by a
[FadeAndTranslate](https://pub.dev/packages/fade_and_translate) widget,
which fades each child in/out while translating their positional offsets.

There are several parameters used to specify the duration, offset, and
additional behavior of the transitions.

```dart
/// A [StackSwapper] built with the default parameters..
StackSwapper(
  myWidget,
  // The duration of the transition animation.
  transitionDuration: Duration(milliseconds: 240),
  // The offset the children translate to during the transition.
  transitionTranslation: Offset(0.0, -24.0),
  // If `true`, the children will translate in opposite directions,
  // if `false`, they'll translate in the same direction.
  invertTranslations: true,
  // If `true`, the first child built will transition from being hidden
  // to being visible, if `false`, it will be built as visible.
  transitionFirstChild: false,
),
```

__Note:__ [StackSwitcher] and [Stacker] have the same default values
for their equivalent parameters as the [STackSwapper] above.

## Callbacks

Each of the widgets also accepts two callbacks, [onSwitchStart] and
[onSwitchComplete], which are called each time a transition starts
and completes, respectively.

```dart
Stacker(
  myWidget,
  // A callback called every time a transition starts.
  onSwitchStart: () => print('Transition starting.'),
  // A callback called every time a transition has completed.
  onSwitchComplete: () => print('Transition completed.'),
);
```
