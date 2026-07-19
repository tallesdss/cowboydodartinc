import 'package:cowboydodartinc/core/data/api/base_api_exceptions.dart';
import 'package:cowboydodartinc/features/feedbacks/api/entities/feature_request_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final featureRequestApiProvider = Provider<FeatureRequestApi>(
  (ref) => FeatureRequestApi(
    client: Supabase.instance.client,
  ),
);

const _kFeatureRequestTable = 'feature_requests';

class FeatureRequestApi {
  final SupabaseClient _client;

  FeatureRequestApi({
    required SupabaseClient client,
  }) : _client = client;

  Future<List<FeatureRequestEntity>> getAllActive() async {
    try {
      final res = await _client
          .from(_kFeatureRequestTable) //
          .select()
          .eq('active', true);
      if (res.isEmpty) {
        return [];
      }
      return res.map((e) => FeatureRequestEntity.fromJson(e)).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  Future<String> create({
    required String title,
    required String description,
  }) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final multilingual = {'en': title, 'pt': title, 'es': title};
      final res = await _client.from(_kFeatureRequestTable).insert({
        'creation_date': now,
        'last_update_date': now,
        'title': multilingual,
        'description': {'en': description, 'pt': description, 'es': description},
        'votes': 0,
        'active': false,
      }).select('id');
      return res.first['id'] as String;
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  /// Admin: every request (active + hidden), highest-voted first.
  Future<List<FeatureRequestEntity>> getAll() async {
    try {
      final res = await _client
          .from(_kFeatureRequestTable) //
          .select()
          .order('votes', ascending: false);
      return res.map((e) => FeatureRequestEntity.fromJson(e)).toList();
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  /// Admin: toggle whether a request is visible (and votable) to users.
  /// Gated server-side by the "Feature requests admin update" RLS policy.
  Future<void> setActive(String id, bool active) async {
    try {
      await _client
          .from(_kFeatureRequestTable) //
          .update({'active': active})
          .eq('id', id);
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }

  /// Admin: update the localized title/description maps (en/pt/es).
  Future<void> updateTexts({
    required String id,
    required Map<String, String> title,
    required Map<String, String> description,
  }) async {
    try {
      await _client.from(_kFeatureRequestTable).update({
        'title': title,
        'description': description,
        'last_update_date': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e, stacktrace) {
      Logger().e('$e: $stacktrace');
      throw ApiError(code: 0, message: '$e: $stacktrace');
    }
  }
}
