import '../../domain/entities/collection_item.dart';
import '../../domain/entities/collection_summary.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_local_datasource.dart';
import '../models/collection_item_model.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionLocalDatasource _datasource;

  CollectionRepositoryImpl(this._datasource);

  @override
  Future<List<CollectionItem>> getItems({
    required String userId,
    String? searchQuery,
    ItemCategory? category,
    ItemStatus? status,
    ItemRarity? rarity,
    ItemCondition? condition,
  }) =>
      _datasource.getItems(
        userId: userId,
        searchQuery: searchQuery,
        category: category?.name,
        status: status?.name,
        rarity: rarity?.name,
        condition: condition?.name,
      );

  @override
  Future<void> addItem(CollectionItem item) =>
      _datasource.insertItem(CollectionItemModel.fromEntity(item));

  @override
  Future<void> updateItem(CollectionItem item) =>
      _datasource.updateItem(CollectionItemModel.fromEntity(item));

  @override
  Future<void> deleteItem(String id, String userId) =>
      _datasource.deleteItem(id, userId);

  @override
  Future<CollectionSummary> getSummary(String userId) async {
    final data = await _datasource.getSummaryData(userId);

    final contagemPorStatus = {
      for (final row
          in data['contagemPorStatus'] as List<Map<String, dynamic>>)
        row['status'] as String: row['count'] as int,
    };
    final valoresRow =
        (data['valores'] as List<Map<String, dynamic>>).first;
    final repetidosRow =
        (data['repetidos'] as List<Map<String, dynamic>>).first;

    final porCategoria = <ItemCategory, int>{};
    for (final row in data['porCategoria'] as List<Map<String, dynamic>>) {
      final cat = ItemCategory.values.firstWhere(
        (e) => e.name == row['category'],
        orElse: () => ItemCategory.other,
      );
      porCategoria[cat] = (porCategoria[cat] ?? 0) + (row['count'] as int);
    }

    return CollectionSummary(
      totalItems: (valoresRow['total'] as int?) ?? 0,
      ownedItems: contagemPorStatus[ItemStatus.owned.name] ?? 0,
      wishlistItems: contagemPorStatus[ItemStatus.wishlist.name] ?? 0,
      soldItems: contagemPorStatus[ItemStatus.sold.name] ?? 0,
      tradedItems: contagemPorStatus[ItemStatus.traded.name] ?? 0,
      loanedItems: contagemPorStatus[ItemStatus.loaned.name] ?? 0,
      repeatedItems: (repetidosRow['count'] as int?) ?? 0,
      totalPaidValue: (valoresRow['total_pago'] as num?)?.toDouble() ?? 0.0,
      totalEstimatedValue:
          (valoresRow['total_estimado'] as num?)?.toDouble() ?? 0.0,
      itemsByCategory: porCategoria,
    );
  }
}
