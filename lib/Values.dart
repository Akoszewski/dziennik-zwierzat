import 'package:flutter/widgets.dart';

double sideMargin = 20;
double statusBarHeight = 24;
double spacing = 20;

String loginUrl = 'https://dziennikhodowlany.pl/admin/users/login';
String indexUrl = "https://dziennikhodowlany.pl/admin/animals/index";

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height - statusBarHeight;
}

double getButtonHeight(BuildContext context) {
  return 0.1015 * getScreenHeight(context);
}

double getFontSize(BuildContext context) {
  return 0.0318 * getScreenHeight(context);
}