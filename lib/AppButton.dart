import 'package:flutter/material.dart';
import 'Values.dart';

class AppButton extends StatelessWidget {
  AppButton({this.label, this.color, this.imgPath, @required this.onPressed});
  final GestureTapCallback onPressed;
  final String imgPath;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonHeight = getButtonHeight(context);

    return Container(
      width: double.infinity,
      height: buttonHeight,
      child: TextButton(
        onPressed: this.onPressed,
        // icon: Image.asset(this.imgPath,
        //     height: 20, width: 20, color: Colors.white),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(this.color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        child: Text(this.label,
            style: TextStyle(
              fontSize: getFontSize(context),
              color: Colors.white,
            )),
      ),
    );
  }
}