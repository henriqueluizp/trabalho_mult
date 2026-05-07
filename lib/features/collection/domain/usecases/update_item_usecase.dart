import '../entities/collection_item.dart';
import '../repositories/collection_repository.dart';

class UpdateItemUseCase {
  final CollectionRepository _repository;
  UpdateItemUseCase(this._repository);

  Future<void> call(CollectionItem item) => _repository.updateItem(item);
}
