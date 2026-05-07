import '../repositories/collection_repository.dart';

class DeleteItemUseCase {
  final CollectionRepository _repository;
  DeleteItemUseCase(this._repository);

  Future<void> call(String id, String userId) =>
      _repository.deleteItem(id, userId);
}
