import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Account {
  final int id;
  final String login;
  final String pass;
  Account({this.id, this.login, this.pass});
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

class AccountSaver {
  AccountSaver._();
  static final AccountSaver asv = AccountSaver._();

  Database _database;
  String _databaseName = 'account.db';
  String _tableName = 'accounts';

  Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    return openDatabase(join(await getDatabasesPath(), _databaseName),
        onCreate: (db, version) async {
      return db.execute(
          "CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, login TEXT, pass TEXT)");
    }, version: 1);
  }

  Future<Database> get database async {
    if (_database != null) { 
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  Future<void> insertAccounts(Account account) async {
    final Database db = await database;
    await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('weszlo');
  }

  Future<List<Account>> accounts() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Account(
        id: maps[i]['id'],
        login: maps[i]['login'],
        pass: maps[i]['pass'],
      );
    });
  }
}
