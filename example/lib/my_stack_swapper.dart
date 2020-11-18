import 'package:flutter/material.dart';
import 'package:stacker/stacker.dart' show StackSwapper;
import 'my_container.dart';

class MyStackSwapper extends StatefulWidget {
  @override
  _MyStackSwapperState createState() => _MyStackSwapperState();
}

class _MyStackSwapperState extends State<MyStackSwapper> {
  final MyContainer _childA = MyContainerA();
  final MyContainer _childB = MyContainerB();
  final MyContainer _childC = MyContainerC();

  Widget _child;

  @override
  void initState() {
    super.initState();
    _child = _childA;
  }

  void _toggleNextChild() {
    switch (_child.runtimeType) {
      case MyContainerA:
        _child = _childB;
        break;
      case MyContainerB:
        _child = _childC;
        break;
      case MyContainerC:
        _child = _childA;
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // StackSwapper
        Center(
          child: StackSwapper(_child),
        ),
        // Toggle Button
        Positioned(
          right: 30.0,
          bottom: 30.0,
          child: FloatingActionButton(
            onPressed: _toggleNextChild,
            child: Icon(Icons.navigate_next),
          ),
        ),
      ],
    );
  }
}

class MyContainerA extends MyContainer {
  MyContainerA() : super('A');
}

class MyContainerB extends MyContainer {
  MyContainerB() : super('B');
}

class MyContainerC extends MyContainer {
  MyContainerC() : super('C');
}
