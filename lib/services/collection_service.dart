import 'package:sqflite/sqflite.dart';
import '../models/collection_item.dart';
import 'database_helper.dart';

class CollectionService {
  final DatabaseHelper _db;
  CollectionService(this._db);

  static const _table = 'items';

  Future<List<CollectionItem>> getItems({
    required String userId,
    String? search,
    ItemCategory? category,
    ItemStatus? status,
    ItemRarity? rarity,
    ItemCondition? condition,
  }) async {
    final db = await _db.database;
    final where = <String>['user_id = ?'];
    final args = <dynamic>[userId];

    if (search != null && search.isNotEmpty) {
      where.add('LOWER(name) LIKE LOWER(?)');
      args.add('%$search%');
    }
    if (category != null) { where.add('category = ?'); args.add(category.name); }
    if (status != null) { where.add('status = ?'); args.add(status.name); }
    if (rarity != null) { where.add('rarity = ?'); args.add(rarity.name); }
    if (condition != null) { where.add('condition = ?'); args.add(condition.name); }

    final rows = await db.query(
      _table,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> addItem(CollectionItem item) async {
    final db = await _db.database;
    await db.insert(_table, _toMap(item),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(CollectionItem item) async {
    final db = await _db.database;
    await db.update(_table, _toMap(item),
        where: 'id = ? AND user_id = ?', whereArgs: [item.id, item.userId]);
  }

  Future<void> deleteItem(String id, String userId) async {
    final db = await _db.database;
    await db.delete(_table,
        where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
  }

  Future<CollectionSummary> getSummary(String userId) async {
    final db = await _db.database;

    final totais = (await db.rawQuery(
      'SELECT COUNT(*) as total, COALESCE(SUM(paid_value),0) as pago, COALESCE(SUM(estimated_value),0) as estimado FROM $_table WHERE user_id = ?',
      [userId],
    )).first;

    final porStatus = {
      for (final r in await db.rawQuery(
          'SELECT status, COUNT(*) as c FROM $_table WHERE user_id = ? GROUP BY status',
          [userId]))
        r['status'] as String: r['c'] as int,
    };

    final repetidos = (await db.rawQuery(
      'SELECT COUNT(*) as c FROM $_table WHERE user_id = ? AND is_repeated = 1',
      [userId],
    )).first['c'] as int;

    final porCategoria = <ItemCategory, int>{};
    for (final r in await db.rawQuery(
        'SELECT category, COUNT(*) as c FROM $_table WHERE user_id = ? GROUP BY category',
        [userId])) {
      final cat = ItemCategory.values.firstWhere(
          (e) => e.name == r['category'], orElse: () => ItemCategory.other);
      porCategoria[cat] = (r['c'] as int);
    }

    return CollectionSummary(
      total: (totais['total'] as int?) ?? 0,
      owned: porStatus[ItemStatus.owned.name] ?? 0,
      wishlist: porStatus[ItemStatus.wishlist.name] ?? 0,
      sold: porStatus[ItemStatus.sold.name] ?? 0,
      traded: porStatus[ItemStatus.traded.name] ?? 0,
      loaned: porStatus[ItemStatus.loaned.name] ?? 0,
      repeated: repetidos,
      totalPaid: (totais['pago'] as num?)?.toDouble() ?? 0,
      totalEstimated: (totais['estimado'] as num?)?.toDouble() ?? 0,
      byCategory: porCategoria,
    );
  }

  CollectionItem _fromMap(Map<String, dynamic> m) => CollectionItem(
        id: m['id'] as String,
        userId: m['user_id'] as String? ?? '',
        name: m['name'] as String,
        category: ItemCategory.values.firstWhere(
            (e) => e.name == m['category'],
            orElse: () => ItemCategory.other),
        status: ItemStatus.values.firstWhere(
            (e) => e.name == m['status'],
            orElse: () => ItemStatus.owned),
        condition: m['condition'] != null
            ? ItemCondition.values.firstWhere(
                (e) => e.name == m['condition'],
                orElse: () => ItemCondition.good)
            : null,
        paidValue: m['paid_value'] as double?,
        estimatedValue: m['estimated_value'] as double?,
        location: m['location'] as String?,
        rarity: ItemRarity.values.firstWhere(
            (e) => e.name == m['rarity'],
            orElse: () => ItemRarity.common),
        notes: m['notes'] as String?,
        imagePath: m['image_path'] as String?,
        isRepeated: (m['is_repeated'] as int? ?? 0) == 1,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        updatedAt: m['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(m['updated_at'] as int)
            : null,
      );

  Map<String, dynamic> _toMap(CollectionItem i) => {
        'id': i.id,
        'user_id': i.userId,
        'name': i.name,
        'category': i.category.name,
        'status': i.status.name,
        'condition': i.condition?.name,
        'paid_value': i.paidValue,
        'estimated_value': i.estimatedValue,
        'location': i.location,
        'rarity': i.rarity.name,
        'notes': i.notes,
        'image_path': i.imagePath,
        'is_repeated': i.isRepeated ? 1 : 0,
        'created_at': i.createdAt.millisecondsSinceEpoch,
        'updated_at': i.updatedAt?.millisecondsSinceEpoch,
      };
}
