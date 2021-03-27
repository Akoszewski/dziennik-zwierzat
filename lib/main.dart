import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

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
String loginUrl = 'https://dziennikhodowlany.pl/admin/users/login';
String indexUrl = "https://dziennikhodowlany.pl/admin/animals/index";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = openDatabase(join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
    return db.execute(
        "CREATE TABLE users(id INTEGER PRIMARY KEY, login TEXT, pass TEXT)");
  }, version: 1);
  runApp(Phoenix(child: MyApp()));
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonHeight = 0.1015 * screenHeight;

    return WillPopScope(
      onWillPop: () async {
        return;
      },
      child: Scaffold(
        body: Center(
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 100,
                left: 100,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Index(indexUrl)),
                    );
                  },
                  child: Text('Moje konto'),
                ),
              ),
              Positioned(
                top: 200,
                left: 100,
                child: TextButton(
                  onPressed: () async {
                    String barcodeScanRes =
                        await FlutterBarcodeScanner.scanBarcode(
                            "#0000ff", "Anuluj", true, null);
                    String urlToGo =
                        "https://dziennikhodowlany.pl/admin/measurements/add?animal_id=" +
                            barcodeScanRes +
                            "&mobile_ver";
                    if (barcodeScanRes != "-1") {
                      print("Scanning result: " + barcodeScanRes);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Index(urlToGo)),
                      );
                    }
                  },
                  child: Text('Pomiary'),
                ),
              ),
              Positioned(
                top: 300,
                left: 100,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        //side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    String barcodeScanRes =
                        await FlutterBarcodeScanner.scanBarcode(
                            "#0000ff", "Anuluj", true, null);
                    String urlToGo =
                        "https://dziennikhodowlany.pl/admin/old-skins/add?animal_id=" +
                            barcodeScanRes +
                            "&mobile_ver";
                    if (barcodeScanRes != "-1") {
                      print("Scanning result: " + barcodeScanRes);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Index(urlToGo)),
                      );
                    }
                  },
                  child: Text('Wylinki'),
                ),
              ),
              Positioned(
                top: 400,
                left: 100,
                child: TextButton(
                  onPressed: () async {
                    String barcodeScanRes =
                        await FlutterBarcodeScanner.scanBarcode(
                            "#0000ff", "Anuluj", true, null);
                    String urlToGo =
                        "https://dziennikhodowlany.pl/admin/feedings/add?animal_id=" +
                            barcodeScanRes +
                            "&mobile_ver";
                    if (barcodeScanRes != "-1") {
                      print("Scanning result: " + barcodeScanRes);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Index(urlToGo)),
                      );
                    }
                  },
                  child: Text('Karmienie'),
                ),
              ),
              Positioned(
                top: 500,
                left: 100,
                child: TextButton(
                  onPressed: () async {
                    Phoenix.rebirth(context);
                  },
                  child: Text('Wyloguj'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Index extends StatelessWidget {
  Index(this.url);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WebView(
          initialUrl: url,
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
                  print("Credentials: " + credentials.toString());
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
