import '../entities/collection_item.dart';
import '../entities/collection_summary.dart';
import '../entities/enums.dart';

abstract class CollectionRepository {
  Future<List<CollectionItem>> getItems({
    required String userId,
    String? searchQuery,
    ItemCategory? category,
    ItemStatus? status,
    ItemRarity? rarity,
    ItemCondition? condition,
  });

  Future<void> addItem(CollectionItem item);
  Future<void> updateItem(CollectionItem item);
  Future<void> deleteItem(String id, String userId);
  Future<CollectionSummary> getSummary(String userId);
}
