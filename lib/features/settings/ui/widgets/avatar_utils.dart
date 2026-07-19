typedef OnAvatarTap = void Function();

final Map<String, String> _avatarUrlCache = {};

void clearAvatarCache([String? userId]) {
  if (userId != null) {
    _avatarUrlCache.remove(userId);
  } else {
    _avatarUrlCache.clear();
  }
}

String? getCachedAvatarUrl(String userId) => _avatarUrlCache[userId];

void cacheAvatarUrl(String userId, String url) {
  if (url.isNotEmpty) _avatarUrlCache[userId] = url;
}

String cacheBustedAvatarUrl(String url, Object version) {
  if (url.isEmpty) return url;
  final uri = Uri.tryParse(url);
  if (uri == null) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$version';
  }
  final query = Map<String, String>.from(uri.queryParameters)
    ..['v'] = version.toString();
  return uri.replace(queryParameters: query).toString();
}

/// Supabase stores the public avatar URL in the user model's avatarPath.
/// The resolver only serves URLs cached after an in-session upload.
Future<String> resolveAvatarUrl(String userId) async {
  return _avatarUrlCache[userId] ?? '';
}
