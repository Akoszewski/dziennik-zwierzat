import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'AccountSaver.dart';
import 'Values.dart';
import 'Menu.dart';

AccountSaver accountSaver;

void main() async {
  accountSaver = AccountSaver();
  await accountSaver.init();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dziennik Hodowlany',
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: LoginPage(title: 'Login page'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WebView(
          initialUrl: loginUrl,
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: Set.from([
            JavascriptChannel(
                name: 'messageHandler',
                onMessageReceived: (JavascriptMessage message) async {
                  print(message.message);
                  var credentials = message.message.split(";");
                  print("Credentials: " + credentials.toString());
                  await accountSaver.insertAccounts(
                      Account(id: 0, login: credentials[0], pass: credentials[1]));
                })
          ]),
          onWebViewCreated: (WebViewController webviewController) {
            _controller = webviewController;
          },
          onPageFinished: (String url) async {
            if (url == loginUrl) {
              var userList = await accountSaver.accounts();
              String login = "";
              String pass = "";
              if (userList.length > 0) {
                var cred = userList[0];
                login = cred.login;
                pass = cred.pass;
              }
              _controller.evaluateJavascript(
                  'document.getElementById("username").value = "$login"');
              _controller.evaluateJavascript(
                  'document.getElementById("password").value = "$pass"');
              _controller.evaluateJavascript(
                  '''document.getElementsByClassName("buttonlogin")[0].onclick =
                                                  function() {
                                                    var login = document.getElementById("username").value
                                                    var pass = document.getElementById("password").value
                                                    messageHandler.postMessage(login+";"+pass);
                                                  }
                                                  ''');
            } else if (url.contains(indexUrl)) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            }
          }),
    );
  }
}
