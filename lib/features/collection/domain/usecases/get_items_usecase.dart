import '../entities/collection_item.dart';
import '../entities/enums.dart';
import '../repositories/collection_repository.dart';

class GetItemsUseCase {
  final CollectionRepository _repository;
  GetItemsUseCase(this._repository);

  Future<List<CollectionItem>> call({
    required String userId,
    String? searchQuery,
    ItemCategory? category,
    ItemStatus? status,
    ItemRarity? rarity,
    ItemCondition? condition,
  }) =>
      _repository.getItems(
        userId: userId,
        searchQuery: searchQuery,
        category: category,
        status: status,
        rarity: rarity,
        condition: condition,
      );
}
