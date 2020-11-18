import 'package:flutter/material.dart';
import 'package:flutter_color_models/flutter_color_models.dart';

class MyContainer extends StatelessWidget {
  MyContainer(this.label)
      : assert(label != null),
        color = HspColor.random(minSaturation: 60, minPerceivedBrightness: 60);

  final String label;

  final Color color;

  @override
  Widget build(BuildContext context) {
    final _bodyWidth = MediaQuery.of(context).size.width;
    final _bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top +
        kToolbarHeight;

    return Container(
      width: _bodyWidth * 0.8,
      height: _bodyHeight * 0.6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 112.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
