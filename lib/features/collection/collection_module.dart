import 'package:get_it/get_it.dart';
import '../../core/database/database_helper.dart';
import 'data/datasources/collection_local_datasource.dart';
import 'data/repositories/collection_repository_impl.dart';
import 'domain/repositories/collection_repository.dart';
import 'domain/usecases/add_item_usecase.dart';
import 'domain/usecases/delete_item_usecase.dart';
import 'domain/usecases/get_items_usecase.dart';
import 'domain/usecases/get_summary_usecase.dart';
import 'domain/usecases/update_item_usecase.dart';
import 'presentation/controllers/collection_controller.dart';
import '../auth/data/datasources/auth_local_datasource.dart';

final getIt = GetIt.instance;

void setupCollectionModule() {
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  getIt.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasource(getIt()),
  );
  getIt.registerLazySingleton<CollectionLocalDatasource>(
    () => CollectionLocalDatasource(getIt()),
  );
  getIt.registerLazySingleton<CollectionRepository>(
    () => CollectionRepositoryImpl(getIt()),
  );

  getIt.registerFactory(() => AddItemUseCase(getIt()));
  getIt.registerFactory(() => UpdateItemUseCase(getIt()));
  getIt.registerFactory(() => DeleteItemUseCase(getIt()));
  getIt.registerFactory(() => GetItemsUseCase(getIt()));
  getIt.registerFactory(() => GetSummaryUseCase(getIt()));

  getIt.registerLazySingleton(
    () => CollectionController(
      addItem: getIt(),
      updateItem: getIt(),
      deleteItem: getIt(),
      getItems: getIt(),
      getSummary: getIt(),
    ),
  );
}
