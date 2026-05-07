import '../entities/collection_summary.dart';
import '../repositories/collection_repository.dart';

class GetSummaryUseCase {
  final CollectionRepository _repository;
  GetSummaryUseCase(this._repository);

  Future<CollectionSummary> call(String userId) =>
      _repository.getSummary(userId);
}
