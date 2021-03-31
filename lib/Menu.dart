import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'AppButton.dart';
import 'Colors.dart';
import 'Index.dart';
import 'Underline.dart';
import 'Values.dart';

class Menu extends StatelessWidget {
  Future<void> scanQr(BuildContext context, String pagename) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#0000ff", "Anuluj", true, null);
    String urlToGo = "https://dziennikhodowlany.pl/admin/" +
        pagename +
        "/add?animal_id=" +
        barcodeScanRes +
        "&mobile_ver";
    if (barcodeScanRes != "-1") {
      print("Scanning result: " + barcodeScanRes);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Index(urlToGo)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonHeight = getButtonHeight(context);
    return WillPopScope(
        onWillPop: () async {
          return;
        },
        child: Scaffold(
          backgroundColor: bgColor,
          body: Container(
            padding: EdgeInsets.only(
                left: 20.0, right: 20.0, top: statusBarHeight, bottom: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.125 * buttonHeight),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                              width: 0.25 * buttonHeight,
                              height: 0.25 * buttonHeight),
                          Image(
                              image: AssetImage('./assets/icon/icon.png'),
                              height: 0.75 * buttonHeight,
                              width: 0.75 * buttonHeight),
                          SizedBox(
                              width: 0.125 * buttonHeight,
                              height: 0.125 * buttonHeight),
                          Text("Dziennik hodowlany",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 1.2 * getFontSize(context))),
                        ],
                      ),
                    ),
                    Underline(),
                    AppButton(
                      label: "Moje konto",
                      imgPath: "./assets/img/icon1.png",
                      color: bgColor,
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Index(indexUrl)),
                        );
                      },
                    ),
                    Underline(),
                    SizedBox(
                      width: double.infinity,
                      height: 0.475 * buttonHeight,
                    ),
                    Row(children: <Widget>[
                      SizedBox(width: 10, height: 10),
                      Text("skanuj QR & dodaj wpis",
                          style: TextStyle(
                            fontSize: getFontSize(context),
                            color: Colors.white,
                          )),
                    ]),
                    SizedBox(width: double.infinity, height: spacing),
                    AppButton(
                      label: "Pomiary",
                      imgPath: "./assets/img/icon2.png",
                      color: buttonColor,
                      onPressed: () async {
                        await scanQr(context, "measurements");
                      },
                    ),
                    SizedBox(width: double.infinity, height: spacing),
                    AppButton(
                      label: "Wylinki",
                      imgPath: "./assets/img/icon3.png",
                      color: buttonColor,
                      onPressed: () async {
                        await scanQr(context, "old-skins");
                      },
                    ),
                    SizedBox(width: double.infinity, height: spacing),
                    AppButton(
                      label: "Karmienie",
                      imgPath: "./assets/img/icon4.png",
                      color: buttonColor,
                      onPressed: () async {
                        await scanQr(context, "feedings");
                      },
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Underline(margin: EdgeInsets.only(bottom: 3)),
                    AppButton(
                      label: "Wyloguj",
                      imgPath: "./assets/img/icon5.png",
                      color: logoutButtonColor,
                      onPressed: () async {
                        Phoenix.rebirth(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}