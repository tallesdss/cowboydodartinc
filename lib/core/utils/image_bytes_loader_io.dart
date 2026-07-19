import 'package:dio/dio.dart';

/// Downloads image bytes on native platforms.
///
/// Native has no browser fetch throttling, so a direct request with a short
/// retry on transient errors (HTTP 429/503, timeouts) is reliable. Returns the
/// raw bytes, or rethrows after exhausting retries so the caller can fall back.
Future<List<int>?> loadImageBytes(String url) async {
  const delays = [Duration(milliseconds: 600), Duration(seconds: 2)];
  for (var attempt = 0; ; attempt++) {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final transient = status == 429 ||
          status == 503 ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError;
      if (!transient || attempt >= delays.length) rethrow;
      await Future<void>.delayed(delays[attempt]);
    }
  }
}
