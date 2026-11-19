import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/api_providers.dart';

/// Informations de santé du questionnaire (objectif, pathologies, allergies).
abstract class HealthRepository {
  Future<void> save({
    required int goal,
    required Set<int> conditions,
    required Set<int> allergies,
  });
}

class MockHealthRepository implements HealthRepository {
  @override
  Future<void> save({
    required int goal,
    required Set<int> conditions,
    required Set<int> allergies,
  }) async {}
}

class ApiHealthRepository implements HealthRepository {
  ApiHealthRepository(this._api);
  final ApiClient _api;

  @override
  Future<void> save({
    required int goal,
    required Set<int> conditions,
    required Set<int> allergies,
  }) async {
    await _api.put(
      '/me/health',
      body: {
        'goal': goal,
        'conditions': conditions.toList()..sort(),
        'allergies': allergies.toList()..sort(),
      },
    );
  }
}

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiHealthRepository(ref.watch(apiClientProvider))
      : MockHealthRepository(),
);
