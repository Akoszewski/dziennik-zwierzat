import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

// Color bgColor = Color(0x373c42);
// Color buttonColor = Color(0x4a4f55);
// Color logoutButtonColor = Color(0x3f424c);

Color bgColor = Colors.grey[850];
Color buttonColor = Colors.grey[700];
Color logoutButtonColor = Color(0x3f424c);

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

double sideMargin = 20;
double statusBarHeight = 24;

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
          // primaryColor: buttonColor,
          // primarySwatch: buttonColor,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: MyHomePage(title: 'Native - JS Communication Bridge'),
    );
  }
}

class AppButton extends StatelessWidget {
  AppButton({this.label, this.color, this.top, this.imgPath, @required this.onPressed});
  final GestureTapCallback onPressed;
  final double top;
  final String imgPath;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonHeight = getButtonHeight(context);
    double btnMargin = 20;

    return Positioned(
      left: btnMargin,
      top: this.top,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
            width: screenWidth - 2 * btnMargin, height: buttonHeight),
        child: TextButton(
          onPressed: this.onPressed,
          // icon: Image.asset(this.imgPath,
          //     height: 20, width: 20, color: Colors.white),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(this.color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                //side: BorderSide(color: Colors.red),
              ),
            ),
          ),
          child: Text(this.label, style: TextStyle(fontSize: getFontSize(context), color: Colors.white,)),
        ),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  Future<void> scanQr(BuildContext context, String pagename) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#0000ff", "Anuluj", true, null);
    String urlToGo = "https://dziennikhodowlany.pl/admin/" +
        pagename +
        "/old-skins/add?animal_id=" +
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
        body: Center(
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.125*buttonHeight + statusBarHeight,
                left: sideMargin,
                child:Row(
                  children: <Widget>[
                    SizedBox(width: 0.25*buttonHeight, height: 0.25*buttonHeight),
                    Image(image: AssetImage('./assets/icon/icon.png'), height: 0.75*buttonHeight, width: 0.75*buttonHeight),
                    SizedBox(width: 0.125*buttonHeight, height: 0.125*buttonHeight),
                    Text("Dziennik hodowlany", style: TextStyle(color: Colors.white, fontSize: 1.2 * getFontSize(context))),
                  ],
                ),
              ),
              Positioned(
                top: 1.125*buttonHeight + statusBarHeight,
                left: sideMargin,
                child: Container(
                  height: 1.0,
                  width: getScreenWidth(context) - 2 * sideMargin,
                  color: buttonColor,
                ),
              ),
              AppButton(
                top: 1.125*buttonHeight + statusBarHeight + 1,
                label: "Moje konto",
                imgPath: "./assets/img/icon1.png",
                color: bgColor,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Index(indexUrl)),
                  );
                },
              ),
              Positioned(
                top: 2.125*buttonHeight + statusBarHeight + 1,
                left: sideMargin,
                child: Container(
                  height: 1.0,
                  width: getScreenWidth(context) - 2 * sideMargin,
                  color: buttonColor,
                ),
              ),
              Positioned (
                top: 2.6*buttonHeight + statusBarHeight + 1,
                left: 30,
                child: Text("skanuj QR & dodaj wpis", style: TextStyle(fontSize: getFontSize(context), color: Colors.white,)),
              ),
              AppButton(
                top: 3.125*buttonHeight + statusBarHeight + 1,
                label: "Pomiary",
                imgPath: "./assets/img/icon2.png",
                color: buttonColor,
                onPressed: () async {
                  await scanQr(context, "measurements");
                },
              ),
              AppButton(
                top: 4.125*buttonHeight + statusBarHeight + 21,
                label: "Wylinki",
                imgPath: "./assets/img/icon3.png",
                color: buttonColor,
                onPressed: () async {
                  await scanQr(context, "old-skins");
                },
              ),
              AppButton(
                top: 5.125*buttonHeight + statusBarHeight + 41,
                label: "Karmienie",
                imgPath: "./assets/img/icon4.png",
                color: buttonColor,
                onPressed: () async {
                  await scanQr(context, "old-skins");
                },
              ),
              AppButton(
                top: 0.864*getScreenHeight(context),
                label: "Wyloguj",
                imgPath: "./assets/img/icon5.png",
                color: buttonColor,
                onPressed: () async {
                  Phoenix.rebirth(context);
                },
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
