import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Communication Bridge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Native - JS Communication Bridge'),
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

  WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Webview')),
      body: WebView(
        initialUrl: 'https://dziennikhodowlany.pl/admin/users/login',
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: 'messageHandler',
              onMessageReceived: (JavascriptMessage message) {
                print(message.message);
              })
        ]),
        onWebViewCreated: (WebViewController webviewController) {
          _controller = webviewController;
          //_loadHtmlFromAssets();
        },
        onPageFinished: (String url) {
          _controller.evaluateJavascript('document.getElementById("username").value = "akoszews@gmail.com"');
          _controller.evaluateJavascript('document.getElementById("password").value = "Haslo123"');
          _controller.evaluateJavascript('''document.getElementsByClassName("buttonlogin")[0].onclick =
                                              function() {
                                                var login = document.getElementById("username").value
                                                var pass = document.getElementById("password").value
                                                messageHandler.postMessage(login+";"+pass);
                                              }
                                              ''');
        }
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.arrow_upward),
      //   onPressed: () {
      //     _controller.evaluateJavascript('fromFlutter("From Flutter")');
      //   },
      // ),
    );
  }

  _loadHtmlFromAssets() async {
    String file = await rootBundle.loadString('assets/index.html');
    _controller.loadUrl(Uri.dataFromString(
        file,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')).toString());
  }

}
