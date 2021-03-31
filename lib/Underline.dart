import 'package:flutter/widgets.dart';
import 'Colors.dart';

class Underline extends StatelessWidget {
  Underline(
      {this.thickness = 2,
      this.color = buttonColor,
      this.margin = EdgeInsets.zero});
  final double thickness;
  final Color color;
  final EdgeInsets margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      margin: margin,
      width: double.infinity,
      color: color,
    );
  }
}