import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _db;
  AuthService(this._db);

  Future<User?> register(String username, String password) async {
    final db = await _db.database;
    final exists = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.trim().toLowerCase()],
    );
    if (exists.isNotEmpty) return null;

    final id = const Uuid().v4();
    await db.insert('users', {
      'id': id,
      'username': username.trim().toLowerCase(),
      'password': password,
    });
    return User(id: id, username: username.trim().toLowerCase());
  }

  Future<User?> login(String username, String password) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim().toLowerCase(), password],
    );
    if (rows.isEmpty) return null;
    return User(
      id: rows.first['id'] as String,
      username: rows.first['username'] as String,
    );
  }
}
