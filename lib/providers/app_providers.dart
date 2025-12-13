import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryo3_app/data/environment_data_source.dart';
import 'package:tryo3_app/data/mock_environment_data_source.dart';
import 'package:tryo3_app/repositories/data_repository.dart';

/// Re-export providers for app-wide usage
/// This file holds global app-level providers

/// Global provider for the EnvironmentDataSource
/// 
/// This is the single point where we define which data source implementation to use.
/// To switch from mock data to a real API:
/// 1. Create ApiEnvironmentDataSource that implements EnvironmentDataSource
/// 2. Change this provider to return ApiEnvironmentDataSource() instead
/// 3. All providers and UI will automatically use the new data source
final environmentDataSourceProvider = Provider<EnvironmentDataSource>((ref) {
  return const MockEnvironmentDataSource();
});

/// Global provider for DataRepository instance
/// 
/// The repository depends on the EnvironmentDataSource, enabling easy switching
/// between different data source implementations without changing any other code.
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  final dataSource = ref.watch(environmentDataSourceProvider);
  return DataRepository(dataSource);
});
