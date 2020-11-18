import 'package:fade_and_translate/fade_and_translate.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'helpers/maintain_state.dart';
import 'stack_base.dart';
import 'stack_switcher.dart';

/// An interface for navigating a [Stack] which displays the last widget
/// of a stack structured [List], transitioning between widgets when a new
/// widget is added or when navigating between widgets already in the stack.
///
/// When navigating backwards in the stack, the widgets in the stack after
/// the one currently being displayed are left hidden in the stack, creating
/// a linear history of the widgets that were previously displayed and can
/// be navigated back to, provided the history hasn't been cleared.
class Stacker extends StatefulStackBase {
  /// An interface for navigating a [Stack] which displays the last widget
  /// in a stack structured [List], transitioning between widgets anytime a
  /// widget is added or when navigating between widgets already in the stack.
  ///
  /// When navigating backwards in the stack, the widgets in the stack after
  /// the one currently being displayed are left hidden in the stack, creating
  /// a linear history of the widgets that were previously displayed and can
  /// be navigated back to, provided the history hasn't been cleared.
  ///
  /// [child] is the first widget to be displayed and exists at the bottom of
  /// the stack. It can not be removed from the stack.
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
  /// [onForwardStart] and [onForwardComplete] are callbacks executed when
  /// the switch transition starts and ends, respectively, but only when
  /// navigating forward in the stack.
  ///
  /// [onBackStart] and [onBackComplete] are callbacks executed when the switch
  /// transition starts and ends, respectively, but only when navigating
  /// back in the stack.
  ///
  /// If [backButton] is `true`, Android's back button will be intercepted
  /// and used to navigating back in the stack.
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
  Stacker(
    this.child, {
    GlobalKey key,
    Duration transitionDuration = const Duration(milliseconds: 240),
    Offset transitionTranslation = const Offset(0.0, 24.0),
    bool invertTranslations = true,
    bool transitionFirstChild = false,
    VoidCallback onSwitchStart,
    VoidCallback onSwitchComplete,
    this.onForwardStart,
    this.onForwardComplete,
    this.callForwardOnBuild = true,
    this.onBackStart,
    this.onBackComplete,
    this.backButton = false,
    bool maintainSizes = false,
    bool maintainAnimations = false,
    bool maintainStates = false,
    TextDirection textDirection,
  })  : assert(child != null),
        assert(transitionDuration != null),
        assert(transitionTranslation != null),
        assert(invertTranslations != null),
        assert(transitionFirstChild != null),
        assert(callForwardOnBuild != null),
        assert(backButton != null),
        assert(maintainSizes != null),
        assert(maintainAnimations != null),
        assert(maintainStates != null),
        super(
          key: key ?? _generateKey(),
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

  /// The root widget.
  final Widget child;

  /// A callback executed when the transition starts while navigating forward.
  final VoidCallback onForwardStart;

  /// A callback executed when the transition ends while navigating forward.
  final VoidCallback onForwardComplete;

  /// If `true`, the [onForwardStart] and [onForwardComplete] callbacks
  /// will be called when a new widget is added to the stack and when
  /// navigating forward in the stack. If `false`, the callbacks will only
  /// be called when navigating forward, but not when a new widget is added.
  final bool callForwardOnBuild;

  /// A callback executed when the transition starts while navigating back.
  final VoidCallback onBackStart;

  /// A callback executed when the transition ends while navigating back.
  final VoidCallback onBackComplete;

  /// If `true`, the device back button can be used to navigate back.
  ///
  /// If the currently displayed widget is the root [child], the back button
  /// will not be intercepted and instead defer to its standard behavior.
  ///
  /// __Note:__ Only supports Android.
  final bool backButton;

  /// Generates a [GlobalKey] used to identify the [Stacker].
  static GlobalKey<_StackerState> _generateKey() => GlobalKey<_StackerState>();

  /// Returns the [key] typecast as a [GlobalKey].
  GlobalKey<_StackerState> get _globalKey => key;

  /// Adds a new widget to the stack and immediately transitions to it.
  ///
  /// If [clearHistory] is `true`, every widget after the one currently
  /// currently displayed in the stack, the forward history, will be removed
  /// after [child] has been inserted.
  void build(
    Widget child, {
    bool clearHistory = true,
    VoidCallback onComplete,
  }) {
    assert(child != null);
    assert(clearHistory != null);

    _globalKey.currentState
        ._buildChild(child, clearHistory: clearHistory, onComplete: onComplete);
  }

  /// Inserts a child into the stack before the one currently being
  /// displayed.
  void prepend(Widget child) {
    assert(child != null);

    _globalKey.currentState._prependChild(child);
  }

  /// Inserts a child into the stack after the one currently being
  /// displayed.
  ///
  /// If [clearHistory] is `true`, every widget after the one currently
  /// being displayed in the stack, the forward history, will be removed
  /// after [child] has been inserted.
  void append(Widget child, {bool clearHistory = true}) {
    assert(child != null);
    assert(clearHistory != null);

    _globalKey.currentState._appendChild(child, clearHistory: clearHistory);
  }

  /// Inserts a [child] into the stack at [index], pushing
  /// every child occuring on or after [index] back.
  void insert(int index, Widget child) {
    assert(index != null && index > 0 && index <= length);
    assert(child != null);

    _globalKey.currentState._insertChild(index, child);
  }

  /// Removes the first instance of [child] from the stack.
  ///
  /// Throws an [UnsupportedError] if the child being removed is
  /// the root child, the [currentChild], or it it doesn't exist
  /// in the stack.
  void remove(Widget child) {
    assert(child != null);

    _globalKey.currentState._removeChild(child);
  }

  /// Removes the child from the stack at [index].
  ///
  /// The [currentChild] and the root [child] may not be removed.
  void removeAt(int index) {
    assert(index != null && index > 0 && index <= length);
    assert(index != currentChild);

    _globalKey.currentState._removeChildAt(index);
  }

  /// Transitions to the previous widget in the stack.
  ///
  /// The [onSwitchStart], [onSwitchComplete], [onBackStart], and
  /// [onBackComlete] callbacks will be called, as well as the [onComplete]
  /// callback if provided, which will be called after the other callbacks.
  ///
  /// Throws a [NavigationError] if the widget currently being
  /// displayed is the root.
  void back({VoidCallback onComplete}) {
    _globalKey.currentState._navigateBack(onComplete: onComplete);
  }

  /// Returns `true` if the root widget is not the widget currently
  /// being displayed.
  bool get canNavigateBack => currentChild == null ? false : currentChild > 0;

  /// Transitions to the next widget in the stack.
  ///
  /// The [onSwitchStart], [onSwitchComplete], [onForwardStart], and
  /// [onForwardComlete] callbacks will be called, as well as the [onComplete]
  /// callback if provided, which will be called after the other callbacks.
  ///
  /// Throws a [NavigationError] if the widget currently being
  /// displayed is the last widget in the stack.
  void forward({VoidCallback onComplete}) {
    _globalKey.currentState._navigateForward(onComplete: onComplete);
  }

  /// Returns `true` if there's at least one widget in the stack after
  /// the widget currently being displayed.
  bool get canNavigateForward =>
      currentChild == null ? false : currentChild < length - 1;

  /// Transitions to the widget at the index defined by [child].
  ///
  /// Only the [onSwitchStart] and [onSwitchComplete] callbacks will be called,
  /// as well as the [onComplete] callback if provided, which will be called
  /// after [onSwitchComplete].
  void open(int index, {VoidCallback onComplete}) {
    assert(index != null && index < length);

    _globalKey.currentState._open(index, onComplete: onComplete);
  }

  /// Transitions to the previous widget in the stack and clears the
  /// forward history when the transition has completed.
  ///
  /// The [onSwitchStart], [onSwitchComplete], [onBackStart], and
  /// [onBackComlete] callbacks will be called, as well as the [onComplete]
  /// callback if provided, which will be called after the other callbacks.
  void pop({VoidCallback onComplete}) {
    _globalKey.currentState._popChild(onComplete: onComplete);
  }

  /// Transitions to the root widget in the stack.
  ///
  /// If [clearHistory] is `true`, every widget in the stack other than
  /// the root [child] will be removed, clearing the entire history.
  ///
  /// Only the [onSwitchStart] and [onSwitchComplete] callbacks will be called,
  /// as well as the [onComplete] callback if provided, which will be called
  /// after [onSwitchComplete].
  void root({bool clearHistory = false, VoidCallback onComplete}) {
    assert(clearHistory != null);

    _globalKey.currentState
        ._openRoot(clearHistory: clearHistory, onComplete: onComplete);
  }

  /// Removes every widget from stack after the one currently
  /// being diplayed, clearing the forward history.
  ///
  /// If [skip] is `> 0`, that number of widgets after the one currently
  /// being displayed will be retained in the history.
  void clearHistory([int skip = 0]) {
    assert(skip != null && skip >= 0);

    _globalKey.currentState._clearHistory(skip);
  }

  /// The index of the child currently being displayed.
  int get currentChild => _globalKey.currentState?._currentChild;

  /// The number of children in the stack.
  int get length => _globalKey.currentState?._children?.length;

  @override
  _StackerState createState() => _StackerState();
}

class _StackerState extends State<Stacker> {
  /// The list of children in the stack.
  final List<Widget> _children = <Widget>[];

  /// The index of the child currently being displayed.
  int _currentChild = 0;

  /// The callback executed when the transition starts.
  VoidCallback _onSwitchStart;

  /// The callback executed when the transition ends.
  VoidCallback _onSwitchComplete;

  /// A controller with access to the methods that control this state.
  ///
  /// It is provided the children and can be accessed via a [BuildContext]
  /// extension, [GetStackerController].
  StackerController _stackerController;

  @override
  void initState() {
    super.initState();

    _stackerController = StackerController._(
      build: _buildChild,
      pop: _popChild,
      prepend: _prependChild,
      append: _appendChild,
      insert: _insertChild,
      remove: _removeChild,
      removeAt: _removeChildAt,
      back: _navigateBack,
      forward: _navigateForward,
      open: _open,
      root: _openRoot,
      clearHistory: _clearHistory,
      getCurrentChild: () => _currentChild,
      getLength: () => _children.length,
    );

    _children.add(widget.child);
  }

  /// Adds a widget to the end of the stack and immediately transitions to it.
  ///
  /// If [clearHistory] is `true`, every widget after the one currently
  /// currently displayed in the stack, the forward history, will be removed
  /// after [child] has been inserted.
  ///
  /// [onComplete] is an optional callback that will be called after the
  /// other callbacks provided by the widget have been called.
  void _buildChild(
    Widget child, {
    bool clearHistory = true,
    VoidCallback onComplete,
  }) {
    assert(child != null);
    assert(clearHistory != null);

    if (clearHistory) _clearHistory();

    _children.add(child);
    _currentChild = _children.length - 1;

    if (widget.callForwardOnBuild) {
      _onSwitchStart = _handleSwitchForwardStart;
      _onSwitchComplete = () {
        _handleSwitchForwardComplete();
        if (onComplete != null) onComplete();
      };
    } else {
      _onSwitchStart = widget.onSwitchStart;
      _onSwitchComplete = () {
        if (widget.onSwitchComplete != null) widget.onSwitchComplete();
        if (onComplete != null) onComplete();
      };
    }

    if (mounted) setState(() {});
  }

  /// Transitions to the previous widget in the stack and clears
  /// the forward history when the transition has completed.
  ///
  /// The [onSwitchStart], [onSwitchComplete], [onBackStart], and
  /// [onBackComlete] callbacks will be called, as well as the [onComplete]
  /// callback if provided, which will be called after the other callbacks.
  void _popChild({VoidCallback onComplete}) {
    _navigateBack(onComplete: () {
      _clearHistory();
      if (onComplete != null) onComplete();
    });
  }

  /// Inserts a child into the stack after the one currently being
  /// displayed.
  void _prependChild(Widget child) {
    assert(child != null);
    assert(build != null);

    _children.insert(_currentChild - 1, child);
    _currentChild++;

    if (mounted) setState(() {});
  }

  /// Inserts a child into the stack after the one currently being
  /// displayed.
  ///
  /// If [clearHistory] is `true`, every widget after the one currently
  /// being displayed in the stack, the forward history, will be removed
  /// after [child] has been inserted.
  void _appendChild(Widget child, {bool clearHistory = true}) {
    assert(child != null);
    assert(build != null);
    assert(clearHistory != null);

    if (clearHistory) _clearHistory();

    _children.insert(_currentChild + 1, child);

    if (mounted) setState(() {});
  }

  /// Inserts the [child] into [_children] at [index].
  ///
  /// [_currentChild] will be increased if necessary to continue
  /// displaying the same widget.
  void _insertChild(int index, Widget child) {
    assert(index != null && index > 0 && index < _children.length);

    _children.insert(index, child);

    if (index <= _currentChild) {
      _currentChild++;
    }

    if (mounted) setState(() {});
  }

  /// Removes the first instance of [child] from [_children].
  ///
  /// Throws an [UnsupportedError] if the child being removed is
  /// the root child, the [_currentChild], or if it doesn't exist
  /// in the stack.
  void _removeChild(Widget child) {
    assert(child != null);

    final index = _children.indexOf(child);

    if (index == -1) {
      throw UnsupportedError('The child wasn\'t found in the stack.');
    }

    if (index == 0) {
      throw UnsupportedError(
          'The root child can not be removed from the stack.');
    }

    if (index == _currentChild) {
      throw UnsupportedError('The child currently being displayed can not be '
          'removed from the stack.');
    }

    _children.removeAt(index);
  }

  /// Removes the child from [_children] at [index].
  ///
  /// The [_currentChild] and the root child may not be removed.
  void _removeChildAt(int index) {
    assert(index != null && index > 0 && index <= _children.length);
    assert(index != _currentChild);

    _children.removeAt(index);
  }

  /// Transitions to the previous widget in the stack.
  ///
  /// [onComplete] is an optional callback that will be called after the
  /// other callbacks provided by the widget have been called.
  ///
  /// Throws a [NavigationError] if the widget currently being
  /// displayed is the root.
  void _navigateBack({VoidCallback onComplete}) {
    if (_currentChild == 0) {
      throw NavigationError('Already displaying the root child. '
          'Cannot navigate any further back.');
    }

    _currentChild--;

    _onSwitchStart = _handleSwitchBackStart;
    _onSwitchComplete = () {
      _handleSwitchBackComplete();
      if (onComplete != null) onComplete();
    };

    if (mounted) setState(() {});
  }

  /// Transitions to the next widget in the stack.
  ///
  /// [onComplete] is an optional callback that will be called after the
  /// other callbacks provided by the widget have been called.
  ///
  /// Throws a [NavigationError] if the widget currently being
  /// displayed is the last widget in the stack.
  void _navigateForward({VoidCallback onComplete}) {
    if (_currentChild == _children.length - 1) {
      throw NavigationError('Already displaying the last child. '
          'Cannot navigate any further forward.');
    }

    _currentChild++;

    _onSwitchStart = _handleSwitchForwardStart;
    _onSwitchComplete = () {
      _handleSwitchForwardComplete();
      if (onComplete != null) onComplete();
    };

    if (mounted) setState(() {});
  }

  /// Transitions to the widget at the index defined by [child].
  ///
  /// Only the [onSwitchStart] and [onSwitchComplete] callbacks will be called,
  /// as well as the [onComplete] callback if provided, which will be called
  /// after [onSwitchComplete].
  void _open(int child, {VoidCallback onComplete}) {
    assert(child != null && child < _children.length);

    _currentChild = child;

    _onSwitchStart = widget.onSwitchStart;
    _onSwitchComplete = () {
      if (widget.onSwitchComplete != null) widget.onSwitchComplete();
      if (onComplete != null) onComplete();
    };

    if (mounted) setState(() {});
  }

  /// Transitions to the root widget in the stack.
  ///
  /// The widgets that were in the stack will remain in the stack in
  /// the order they were opened if [clearHistory] is `false`. If `true`,
  /// every widget other than the root widget will be removed from the stack,
  /// clearing the history.
  ///
  /// [onComplete] is an optional callback that will be called after the
  /// other callbacks provided by the widget have been called.
  void _openRoot({
    bool clearHistory = false,
    VoidCallback onComplete,
  }) {
    assert(clearHistory != null);

    _currentChild = 0;

    _onSwitchStart = widget.onSwitchStart;
    _onSwitchComplete = () {
      if (clearHistory) _clearHistory();
      if (widget.onSwitchComplete != null) widget.onSwitchComplete();
      if (onComplete != null) onComplete();
    };

    if (mounted) setState(() {});
  }

  /// Removes every widget from [_children] after the one currently
  /// being diplayed, clearing the forward history.
  ///
  /// If [skip] is `> 0`, that number of widgets past the one currently
  /// being displayed will be retained in the history.
  void _clearHistory([int skip = 0]) {
    assert(skip != null && skip >= 0);

    final removeFrom = _currentChild + 1 + skip;

    if (removeFrom < _children.length) {
      _children.removeRange(removeFrom, _children.length);
    }
  }

  /// Executes [widget.onSwitchStart] and [widget.onBackStart] when
  /// called by the [StackSwitcher]'s [onSwitchComplete] callback.
  void _handleSwitchBackStart() {
    if (widget.onSwitchStart != null) widget.onSwitchStart();
    if (widget.onBackStart != null) widget.onBackStart();
  }

  /// Executes [widget.onSwitchComplete] and [widget.onBackComplete] when
  /// called by the [StackSwitcher]'s [onSwitchComplete] callback.
  void _handleSwitchBackComplete() {
    if (widget.onSwitchComplete != null) widget.onSwitchComplete();
    if (widget.onBackComplete != null) widget.onBackComplete();
  }

  /// Executes [widget.onSwitchStart] and [widget.onForwardStart] when
  /// called by the [StackSwitcher]'s [onSwitchComplete] callback.
  void _handleSwitchForwardStart() {
    if (widget.onSwitchStart != null) widget.onSwitchStart();
    if (widget.onForwardStart != null) widget.onForwardStart();
  }

  /// Executes [widget.onSwitchComplete] and [widget.onForwardComplete] when
  /// called by the [StackSwitcher]'s [onSwitchComplete] callback.
  void _handleSwitchForwardComplete() {
    if (widget.onSwitchComplete != null) widget.onSwitchComplete();
    if (widget.onForwardComplete != null) widget.onForwardComplete();
  }

  /// Called by the [WillPopScope] in the [build]er to navigate back to
  /// the previous child in the stack when the back button is pressed,
  /// unless the current child is the root.
  Future<bool> _handleBackButton() async {
    if (_currentChild == 0) {
      return true;
    }

    _navigateBack();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<StackerController>(
      create: (_) => _stackerController,
      child: WillPopScope(
        onWillPop: widget.backButton ? _handleBackButton : null,
        child: StackSwitcher(
          _children,
          child: _currentChild,
          transitionDuration: widget.transitionDuration,
          transitionTranslation: widget.transitionTranslation,
          invertTranslations: widget.invertTranslations,
          onSwitchStart: _onSwitchStart,
          onSwitchComplete: _onSwitchComplete,
          maintainStates: widget.maintainStates,
          maintainAnimations: widget.maintainAnimations,
          maintainSizes: widget.maintainSizes,
          textDirection: widget.textDirection,
        ),
      ),
    );
  }
}

/// The method used by the [Stacker] to build new children.
typedef BuildChild = void Function(Widget child,
    {bool clearHistory, VoidCallback onComplete});

/// The method used by [Stacker] to insert a [child] into the
/// stack before the one currenty being displayed.
typedef PrependChild = void Function(Widget child);

/// The method used by [Stacker] to insert a [child] into the
/// stack after the one currently being displayed.
typedef AppendChild = void Function(Widget child, {bool clearHistory});

/// The method used by [Stacker] to insert a [child] into the
/// stack at [index].
typedef InsertChild = void Function(int index, Widget child);

/// The method used by [Stacker] to remove a [child] from the stack.
typedef RemoveChild = void Function(Widget child);

/// The method used by [Stacker] to remove a child from the stack at [index].
typedef RemoveChildAt = void Function(int index);

/// The method used by [Stacker] to navigate to the child in
/// the stack before the one currently being displayed.
typedef NavigateBack = void Function({VoidCallback onComplete});

/// The method used by [Stacker] to navigate to the child in
/// the stack after the one currently being displayed.
typedef NavigateForward = void Function({VoidCallback onComplete});

/// The method used by [Stacker] to navigate to the child in
/// the stack at [index].
typedef NavigateTo = void Function(int index, {VoidCallback onComplete});

/// The method used by [Stacker] to navigate to the root child.
typedef NavigateToRoot = void Function(
    {bool clearHistory, VoidCallback onComplete});

/// The method used by [Stacker] to navigate to the previous
/// widget in the stack and remove every child occuring after it from
/// the stack.
typedef PopChild = void Function({VoidCallback onComplete});

/// The method used by [Stacker] to remove every child in the stack
/// occuring after the child currently being displayed.
typedef ClearHistory = void Function([int skip]);

/// Type definition for methods that return an [int]; used to get
/// the index of the current child and the length of the stack.
typedef _GetInt = int Function();

/// The methods for building widgets into and navigating a [Stacker].
class StackerController {
  const StackerController._({
    @required this.build,
    @required this.pop,
    @required this.prepend,
    @required this.append,
    @required this.insert,
    @required this.remove,
    @required this.removeAt,
    @required this.back,
    @required this.forward,
    @required this.open,
    @required this.root,
    @required this.clearHistory,
    @required _GetInt getCurrentChild,
    @required _GetInt getLength,
  })  : assert(build != null),
        assert(prepend != null),
        assert(append != null),
        assert(insert != null),
        assert(remove != null),
        assert(removeAt != null),
        assert(back != null),
        assert(forward != null),
        assert(open != null),
        assert(root != null),
        assert(pop != null),
        assert(clearHistory != null),
        assert(getCurrentChild != null),
        assert(getLength != null),
        _getCurrentChild = getCurrentChild,
        _getLength = getLength;

  /// Adds a new widget to the [Stacker] and immediately transitions to it.
  ///
  /// If [clearHistory] is `true`, every widget after the one currently
  /// currently displayed in the stack, the forward history, will be removed
  /// after [child] has been inserted.
  final BuildChild build;

  /// Inserts a child into the stacker before the one currently being
  /// displayed.
  final PrependChild prepend;

  /// Inserts a child into the stack after the one currently being
  /// displayed.
  ///
  /// If [clearHistory] is `true`, every widget after the one currently
  /// being displayed in the stack, the forward history, will be removed
  /// after [child] has been inserted.
  final AppendChild append;

  /// Inserts a [child] into the stack at [index].
  final InsertChild insert;

  /// Removes the first instance of [child] from the stack.
  ///
  /// Throws an [UnsupportedError] if the child being removed is
  /// the root child, the [currentChild], or it it doesn't exist
  /// in the stack.
  final RemoveChild remove;

  /// Removes the child from the stack at [index].
  ///
  /// The [currentChild] and the root [child] may not be removed.
  final RemoveChildAt removeAt;

  /// Transitions to the previous widget in the [Stacker]'s stack.
  ///
  /// Throws a [NavigationError] if the widget currently being
  /// displayed is the root.
  final NavigateBack back;

  /// Transitions to the next widget in the [Stacker]'s stack.
  ///
  /// Throws a [NavigationError] if the widget currently being
  /// displayed is the last widget in the stack.
  final NavigateForward forward;

  /// Transitions to the widget in the [Stacker]'s stack at [index].
  final NavigateTo open;

  /// Transitions to the root widget in the [Stacker]'s stack.
  ///
  /// __Note:__ Doesn't do anything if the root is already being displayed.
  final NavigateToRoot root;

  /// Transitions to the previous widget in the stack, then
  /// removes the one that was being displayed.
  ///
  /// The [onSwitchStart], [onSwitchComplete], [onBackStart], and
  /// [onBackComlete] callbacks will be called, as well as the [onComplete]
  /// callback if provided, which will be called last.
  final PopChild pop;

  /// Removes every widget from [_children] after the one currently
  /// being diplayed, clearing the forward history.
  final ClearHistory clearHistory;

  /// Gets the index of the child currently being displayed.
  final _GetInt _getCurrentChild;

  /// The index of the child currently being displayed.
  int get currentChild => _getCurrentChild();

  /// Gets the number of children in the stack.
  final _GetInt _getLength;

  /// The number of children in the stack.
  int get length => _getLength();
}

/// Adds a getter to [BuildContext] to retrieve a controller for
/// building and navigating widgets in a [Stacker].
extension GetStackerController on BuildContext {
  /// A controller with the methods necessary for building and navigating
  /// widgets in a [Stacker].
  StackerController get stacker =>
      Provider.of<StackerController>(this, listen: false);
}

/// An error thrown when attempting to navigate forward or back in the
/// stack when the currently displayed widget is already the first or last
/// widget in the stack.
class NavigationError extends UnsupportedError {
  NavigationError(String message)
      : assert(message != null),
        super(message);
}
