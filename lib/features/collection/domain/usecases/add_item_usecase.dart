import '../entities/collection_item.dart';
import '../repositories/collection_repository.dart';

class AddItemUseCase {
  final CollectionRepository _repository;
  AddItemUseCase(this._repository);

  Future<void> call(CollectionItem item) => _repository.addItem(item);
}
