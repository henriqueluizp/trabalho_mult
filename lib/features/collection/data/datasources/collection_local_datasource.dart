import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/collection_item_model.dart';

class CollectionLocalDatasource {
  final DatabaseHelper _dbHelper;

  CollectionLocalDatasource(this._dbHelper);

  static const _table = 'collection_items';

  Future<List<CollectionItemModel>> getItems({
    required String userId,
    String? searchQuery,
    String? category,
    String? status,
    String? rarity,
    String? condition,
  }) async {
    final db = await _dbHelper.database;
    final condicoes = <String>['user_id = ?'];
    final args = <dynamic>[userId];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      condicoes.add('LOWER(name) LIKE LOWER(?)');
      args.add('%$searchQuery%');
    }
    if (category != null) { condicoes.add('category = ?'); args.add(category); }
    if (status != null) { condicoes.add('status = ?'); args.add(status); }
    if (rarity != null) { condicoes.add('rarity = ?'); args.add(rarity); }
    if (condition != null) { condicoes.add('condition = ?'); args.add(condition); }

    final linhas = await db.query(
      _table,
      where: condicoes.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return linhas.map(CollectionItemModel.fromMap).toList();
  }

  Future<void> insertItem(CollectionItemModel item) async {
    final db = await _dbHelper.database;
    await db.insert(_table, item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Só atualiza se o item pertence ao usuário
  Future<void> updateItem(CollectionItemModel item) async {
    final db = await _dbHelper.database;
    await db.update(
      _table,
      item.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [item.id, item.userId],
    );
  }

  // Só deleta se o item pertence ao usuário
  Future<void> deleteItem(String id, String userId) async {
    final db = await _dbHelper.database;
    await db.delete(
      _table,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<Map<String, dynamic>> getSummaryData(String userId) async {
    final db = await _dbHelper.database;
    return {
      'contagemPorStatus': await db.rawQuery(
        'SELECT status, COUNT(*) as count FROM $_table WHERE user_id = ? GROUP BY status',
        [userId],
      ),
      'repetidos': await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_table WHERE user_id = ? AND is_repeated = 1',
        [userId],
      ),
      'valores': await db.rawQuery(
        '''SELECT COUNT(*) as total,
           COALESCE(SUM(paid_value), 0.0) as total_pago,
           COALESCE(SUM(estimated_value), 0.0) as total_estimado
           FROM $_table WHERE user_id = ?''',
        [userId],
      ),
      'porCategoria': await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM $_table WHERE user_id = ? GROUP BY category',
        [userId],
      ),
    };
  }
}

