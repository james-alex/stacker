import 'package:flutter/material.dart';
import 'package:stacker/stacker.dart' show StackSwitcher;
import 'my_container.dart';

class MyStackSwitcher extends StatefulWidget {
  @override
  _MyStackSwitcherState createState() => _MyStackSwitcherState();
}

class _MyStackSwitcherState extends State<MyStackSwitcher> {
  final List<Widget> _children = [
    MyContainer('1'),
    MyContainer('2'),
    MyContainer('3'),
    MyContainer('4'),
    MyContainer('5'),
  ];

  int _child = 0;

  void _navigateTo(int childIndex) {
    _child = childIndex;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // StackSwitcher
        Center(
          child: StackSwitcher(
            _children,
            child: _child,
          ),
        ),
        // Controls
        Positioned(
          width: MediaQuery.of(context).size.width,
          bottom: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavButton(0, onTap: _navigateTo),
              _NavButton(1, onTap: _navigateTo),
              _NavButton(2, onTap: _navigateTo),
              _NavButton(3, onTap: _navigateTo),
              _NavButton(4, onTap: _navigateTo),
            ],
          ),
        ),
      ],
    );
  }
}

typedef NavigateTo = void Function(int index);

class _NavButton extends StatelessWidget {
  const _NavButton(this.index, {this.onTap})
      : assert(index != null),
        assert(onTap != null);

  final int index;

  final NavigateTo onTap;

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.of(context).size.width / 10).clamp(0.0, 60.0);

    return Padding(
      padding: EdgeInsets.all(size / 3),
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontSize: size / 2.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
