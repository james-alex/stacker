import 'package:flutter/material.dart';
import 'package:modular_menu/modular_menu.dart';
import 'package:stacker/stacker.dart';
import 'my_stack_swapper.dart';
import 'my_stack_switcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stacker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Stacker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// A [Stacker] with a [MyStackSwapper] as the root widget,
  /// set up to handle a single-page navigation system.
  final Stacker _myStacker = Stacker(
    MyStackSwapper(),
    maintainStates: true,
    backButton: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Back Navigation Button
          NavigationButton(
            Icons.arrow_back,
            onTap: _myStacker.back,
            setState: setState,
            enabled: _myStacker.canNavigateBack,
          ),
          // Forward Navigation Button
          NavigationButton(
            Icons.arrow_forward,
            onTap: _myStacker.forward,
            setState: setState,
            enabled: _myStacker.canNavigateForward,
          ),
        ],
      ),
      drawer: Drawer(
        child: ModularMenu(
          [
            // Build and navigate to a new [MyStackSwapper] when pressed.
            MenuButton('StackSwapper', onTap: () {
              _myStacker.build(MyStackSwapper());
              setState(() {});
            }),
            // Build and navigate to a new [MyStackSwitcher] when pressed.
            MenuButton('StackSwitcher', onTap: () {
              _myStacker.build(MyStackSwitcher());
              setState(() {});
            }),
          ],
          // Close the drawer when any button is pressed.
          onTapAny: () => Navigator.pop(context),
        ),
      ),
      body: _myStacker,
    );
  }
}

typedef StateSetter = void Function(void Function());

class NavigationButton extends StatelessWidget {
  const NavigationButton(
    this.icon, {
    @required this.onTap,
    @required this.setState,
    @required this.enabled,
  })  : assert(icon != null),
        assert(onTap != null),
        assert(setState != null),
        assert(enabled != null);

  final IconData icon;

  final GestureTapCallback onTap;

  final StateSetter setState;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () {
              onTap();
              setState(() {});
            }
          : null,
      child: Container(
        width: 48.0,
        child: Center(
          child: Icon(icon, color: enabled ? Colors.white : Colors.white30),
        ),
      ),
    );
  }
}
