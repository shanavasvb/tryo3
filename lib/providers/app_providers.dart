import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryo3_app/repositories/data_repository.dart';

/// Re-export the data repository provider for app-wide usage
/// This file can hold additional app-level providers in the future

/// Global provider for DataRepository instance
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepository();
});
