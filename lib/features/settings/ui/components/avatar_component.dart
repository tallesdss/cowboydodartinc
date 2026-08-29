import 'dart:async';
import 'dart:typed_data';

import 'package:cowboydodartinc/components/kasy_avatar.dart';
import 'package:cowboydodartinc/components/kasy_bottom_sheet.dart';
import 'package:cowboydodartinc/core/data/entities/upload_result.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/data/repositories/user_repository.dart';
import 'package:cowboydodartinc/core/states/models/user_state.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/avatar_utils.dart';
import 'package:cowboydodartinc/features/settings/ui/widgets/round_progress.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Displays the user avatar using [KasyAvatar] with soft-icon fallback.
/// Tapping opens the gallery to upload a new photo.
/// Shows a circular progress ring and fade animation during upload.
class EditableUserAvatar extends ConsumerStatefulWidget {
  final OnAvatarTap? onTap;
  final double? diameter;

  const EditableUserAvatar({super.key, this.onTap, this.diameter});

  @override
  ConsumerState<EditableUserAvatar> createState() => _EditableUserAvatarState();
}

class _EditableUserAvatarState extends ConsumerState<EditableUserAvatar> {
  Uint8List? temporaryAvatarBytes;
  StreamSubscription<UploadResult>? _saveAvatarSubscription;
  double? uploadProgress;
  bool _isUploading = false;
  String? _optimisticAvatarUrl;
  bool _hovered = false;

  ImageProvider? get _temporaryAvatarImage {
    final bytes = temporaryAvatarBytes;
    return bytes == null ? null : MemoryImage(bytes);
  }

  @override
  void dispose() {
    _saveAvatarSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateNotifierProvider);
    final userId = userState.user.idOrNull;
    final avatarPath = switch (userState.user) {
      AuthenticatedUserData(:final avatarPath) => avatarPath,
      _ => null,
    };
    final displayAvatarPath = _optimisticAvatarUrl ?? avatarPath;
    final double d = widget.diameter ?? KasyAvatarSize.medium.diameter;

    // Desktop only (>= 1024): Stripe-style direct edit. Mobile/tablet keep the
    // bottom sheet (camera/gallery/remove), which also covers touch + camera.
    final bool isDesktop =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;

    final cachedUrl = userId == null ? null : getCachedAvatarUrl(userId);
    final bool hasAvatar = _hasAvatarUrl(displayAvatarPath) ||
        _hasAvatarUrl(cachedUrl) ||
        temporaryAvatarBytes != null;

    final bool canEdit = userId != null && !_isUploading;
    final VoidCallback? onTapAvatar = !canEdit
        ? null
        : isDesktop
            // Desktop: clicking anywhere opens the file picker directly.
            ? () => _pickAndUpload(ImageSource.gallery, userState)
            : () => _onTapAvatar(context, userState, avatarPath);

    // The hover "x" to remove is desktop-only and only when a photo exists.
    final bool showRemoveBadge =
        isDesktop && hasAvatar && _hovered && !_isUploading;

    return KasyFocusRing(
      enabled: onTapAvatar != null,
      onActivate: onTapAvatar,
      borderRadius: BorderRadius.circular(KasyRadius.full),
      child: MouseRegion(
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapAvatar,
          child: Padding(
          padding: const EdgeInsets.all(6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _AvatarFadeAnimation(
                isUploading: _isUploading,
                child: _AvatarContent(
                  diameter: d,
                  localImage: _temporaryAvatarImage,
                  userId: userId,
                  avatarPath: displayAvatarPath,
                ),
              ),
              if (_isUploading)
                Positioned.fill(
                  child: RoundProgress(
                    color: context.colors.primary.withValues(alpha: .6),
                    radius: d / 2,
                    progress: uploadProgress,
                  ),
                ),
              // No camera hint on desktop: clicking anywhere already re-uploads,
              // and hover shows the remove "x". Mobile/tablet keep the badge.
              if (!isDesktop)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      KasyIcons.cameraAlt,
                      size: KasyIconSize.xxs,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (showRemoveBadge)
                Positioned(
                  // Same corner the camera badge uses on mobile/tablet: on
                  // desktop that corner is empty until hover, when it shows "x".
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _removeAvatar(userState),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          KasyIcons.close,
                          size: KasyIconSize.xxs,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTapAvatar(
    BuildContext context,
    UserState userState,
    String? avatarPath,
  ) {
    final userId = userState.user.idOrNull;
    final cachedUrl = userId == null ? null : getCachedAvatarUrl(userId);
    final hasAvatar =
        _hasAvatarUrl(avatarPath) ||
        _hasAvatarUrl(cachedUrl) ||
        temporaryAvatarBytes != null;
    final avatar = t.settings.avatar;
    return showKasyChoiceSheet<void>(
      context: context,
      title: avatar.title,
      options: [
        KasyBottomSheetOption(
          icon: KasyIcons.cameraAlt,
          label: avatar.take_photo,
          onTap: () => _pickAndUpload(ImageSource.camera, userState),
        ),
        KasyBottomSheetOption(
          icon: KasyIcons.gallery,
          label: avatar.choose_library,
          onTap: () => _pickAndUpload(ImageSource.gallery, userState),
        ),
        if (hasAvatar)
          KasyBottomSheetOption(
            icon: KasyIcons.trash,
            label: avatar.remove_photo,
            danger: true,
            onTap: () => _removeAvatar(userState),
          ),
      ],
    );
  }

  Future<void> _pickAndUpload(ImageSource source, UserState userState) async {
    final file = await ImagePicker().pickImage(source: source);
    if (!mounted) return;
    await _uploadTask(file, userState);
  }

  Future<void> _uploadTask(XFile? file, UserState userState) async {
    if (file == null) return;
    final userId = userState.user.idOrNull;
    if (userId == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;

    await _saveAvatarSubscription?.cancel();
    _saveAvatarSubscription = null;
    setState(() {
      temporaryAvatarBytes = bytes;
      uploadProgress = null;
      _isUploading = true;
      _optimisticAvatarUrl = null;
    });

    _saveAvatarSubscription = ref
        .read(userRepositoryProvider)
        .saveAvatar(userId: userId, data: bytes)
        .listen(
          (event) {
            switch (event) {
              case UploadResultProgress():
                _updateUploadProgress(event.progress);
              case UploadResultCompleted():
                _finishUpload(userId, event.imagePublicUrl);
            }
          },
          onError: (e, s) {
            _resetUploadState(clearPreview: true);
          },
          onDone: () => _resetUploadState(clearPreview: false),
          cancelOnError: true,
        );
  }

  void _finishUpload(String userId, String newUrl) {
    final oldUrl = getCachedAvatarUrl(userId);
    final version = DateTime.now().millisecondsSinceEpoch;
    final displayUrl = cacheBustedAvatarUrl(newUrl, version);

    _evictAvatarImage(oldUrl);
    _evictAvatarImage(newUrl);
    _evictAvatarImage(displayUrl);

    if (displayUrl.isNotEmpty) {
      cacheAvatarUrl(userId, displayUrl);
    }
    unawaited(ref.read(userStateNotifierProvider.notifier).onUpdateAvatar());
    unawaited(_saveAvatarSubscription?.cancel());
    _saveAvatarSubscription = null;
    if (!mounted) return;
    setState(() {
      uploadProgress = null;
      _isUploading = false;
      _optimisticAvatarUrl = displayUrl.isEmpty ? null : displayUrl;
    });
  }

  Future<void> _removeAvatar(UserState userState) async {
    final userId = userState.user.idOrNull;
    if (userId == null) return;
    final cachedUrl = getCachedAvatarUrl(userId);
    final avatarPath = switch (userState.user) {
      AuthenticatedUserData(:final avatarPath) => avatarPath,
      _ => null,
    };
    setState(() {
      temporaryAvatarBytes = null;
      _optimisticAvatarUrl = null;
      uploadProgress = null;
      _isUploading = false;
    });
    await ref.read(userRepositoryProvider).deleteAvatar(userId: userId);
    _evictAvatarImage(cachedUrl);
    _evictAvatarImage(avatarPath);
    clearAvatarCache(userId);
    unawaited(ref.read(userStateNotifierProvider.notifier).onUpdateAvatar());
  }

  void _updateUploadProgress(double progress) {
    if (!mounted) return;
    final normalized = _normalizeProgress(progress);
    setState(() {
      uploadProgress = normalized <= 0 ? null : normalized;
    });
  }

  double _normalizeProgress(double progress) {
    if (!progress.isFinite || progress <= 0) return 0.0;
    if (progress >= 1) return 1.0;
    return progress;
  }

  void _resetUploadState({required bool clearPreview}) {
    unawaited(_saveAvatarSubscription?.cancel());
    _saveAvatarSubscription = null;
    if (!mounted || !_isUploading) return;
    setState(() {
      if (clearPreview) {
        temporaryAvatarBytes = null;
      }
      uploadProgress = null;
      _isUploading = false;
    });
  }

  void _evictAvatarImage(String? url) {
    if (url == null || url.isEmpty) return;
    PaintingBinding.instance.imageCache.evict(NetworkImage(url));
  }

  bool _hasAvatarUrl(String? url) {
    return url != null && url.isNotEmpty;
  }
}


/// Resolves the avatar [ImageProvider] and renders a [KasyAvatar] with
/// [KasyAvatarFallbackSurface.soft]. Firebase Storage URL is loaded async.
class _AvatarContent extends StatelessWidget {
  final double diameter;
  final ImageProvider? localImage;
  final String? userId;
  final String? avatarPath;

  const _AvatarContent({
    required this.diameter,
    this.localImage,
    this.userId,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Temporary file picked from the gallery (highest priority)
    if (localImage != null) {
      return KasyAvatar(
        diameter: diameter,
        image: localImage,
        fallbackSurface: KasyAvatarFallbackSurface.soft,
        tone: KasyAvatarTone.neutral,
      );
    }

    final path = avatarPath;
    if (path != null && path.isNotEmpty) {
      final bustedUrl = cacheBustedAvatarUrl(path, DateTime.now().millisecondsSinceEpoch);
      return KasyAvatar(
        diameter: diameter,
        image: NetworkImage(bustedUrl),
        fallbackSurface: KasyAvatarFallbackSurface.soft,
        tone: KasyAvatarTone.neutral,
      );
    }

    final id = userId;
    if (id != null) {
      // 2. Cached URL: synchronous, no FutureBuilder, no fallback flash
      final cachedUrl = getCachedAvatarUrl(id);
      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        return KasyAvatar(
          diameter: diameter,
          image: NetworkImage(cachedUrl),
          fallbackSurface: KasyAvatarFallbackSurface.soft,
          tone: KasyAvatarTone.neutral,
        );
      }

      // 3. URL not cached: async fetch (first access or after upload)
      return FutureBuilder<String>(
        future: resolveAvatarUrl(id),
        builder: (context, snapshot) {
          final url = snapshot.data;
          return KasyAvatar(
            diameter: diameter,
            image: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
            fallbackSurface: KasyAvatarFallbackSurface.soft,
            tone: KasyAvatarTone.neutral,
          );
        },
      );
    }

    // 4. Guest: fallback suave
    return KasyAvatar(
      diameter: diameter,
      fallbackSurface: KasyAvatarFallbackSurface.soft,
      tone: KasyAvatarTone.neutral,
    );
  }
}

/// Fades the avatar to 0.6 opacity during upload and back to 1.0 when done.
class _AvatarFadeAnimation extends StatelessWidget {
  final Widget child;
  final bool isUploading;

  const _AvatarFadeAnimation({required this.child, required this.isUploading});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isUploading ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: child,
    );
  }
}
