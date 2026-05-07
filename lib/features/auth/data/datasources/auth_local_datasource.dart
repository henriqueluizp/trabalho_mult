import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/user.dart';

class AuthLocalDatasource {
  final DatabaseHelper _dbHelper;

  AuthLocalDatasource(this._dbHelper);

  Future<User?> register(String username, String password) async {
    final db = await _dbHelper.database;

    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.trim().toLowerCase()],
    );
    if (existing.isNotEmpty) return null;

    final id = const Uuid().v4();
    await db.insert('users', {
      'id': id,
      'username': username.trim().toLowerCase(),
      'password': password,
    });

    return User(id: id, username: username.trim().toLowerCase());
  }

  Future<User?> login(String username, String password) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim().toLowerCase(), password],
    );
    if (result.isEmpty) return null;
    return User(
      id: result.first['id'] as String,
      username: result.first['username'] as String,
    );
  }
}
