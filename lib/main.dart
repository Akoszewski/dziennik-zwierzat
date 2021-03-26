import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class User {
  final int id;
  final String login;
  final String pass;
  User({this.id, this.login, this.pass});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'login': login,
      'pass': pass,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, login: $login, pass: $pass}';
  }
}

Future<Database> database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = openDatabase(join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
    return db.execute(
        "CREATE TABLE users(id INTEGER PRIMARY KEY, login TEXT, pass TEXT)");
  }, version: 1);
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

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Second Route"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to first route when tapped.
            },
            child: Text('Go back!'),
          ),
        ),
      ),
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
  String loginUrl = 'https://dziennikhodowlany.pl/admin/users/login';
  String indexUrl = "https://dziennikhodowlany.pl/admin/animals/index";

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
                  Future<void> insertUser(User user) async {
                    final Database db = await database;
                    await db.insert(
                      'users',
                      user.toMap(),
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );
                  }

                  print(message.message);
                  var credentials = message.message.split(";");
                  await insertUser(
                      User(id: 0, login: credentials[0], pass: credentials[1]));
                })
          ]),
          onWebViewCreated: (WebViewController webviewController) {
            _controller = webviewController;
            //_loadHtmlFromAssets();
          },
          onPageFinished: (String url) async {
            if (url == loginUrl) {
              Future<List<User>> users() async {
                final Database db = await database;
                final List<Map<String, dynamic>> maps = await db.query('users');
                return List.generate(maps.length, (i) {
                  return User(
                    id: maps[i]['id'],
                    login: maps[i]['login'],
                    pass: maps[i]['pass'],
                  );
                });
              }
              var userList = await users();
              var cred = userList[0];
              String login = cred.login;
              String pass = cred.pass;
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
