import 'package:cowboydodartinc/features/subscriptions/ui/component/paywall_trial_palette.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const String kPaywallTrialVideoAsset = 'assets/video-background.mp4';

/// Looping hero video with the same bottom-up gradient fade as [PaywallSolo].
class PaywallTrialVideoBackdrop extends StatefulWidget {
  const PaywallTrialVideoBackdrop({super.key});

  @override
  State<PaywallTrialVideoBackdrop> createState() =>
      _PaywallTrialVideoBackdropState();
}

class _PaywallTrialVideoBackdropState extends State<PaywallTrialVideoBackdrop> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(kPaywallTrialVideoAsset);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) {
        return;
      }
      setState(() => _ready = true);
      await controller.play();
    } on Object {
      if (mounted) {
        setState(() => _ready = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: PaywallTrialPalette.canvasDeep),
        if (_ready && controller != null)
          FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                PaywallTrialPalette.canvas,
                PaywallTrialPalette.canvas,
                PaywallTrialPalette.canvas.withValues(alpha: 0.92),
                PaywallTrialPalette.canvas.withValues(alpha: 0.45),
                PaywallTrialPalette.canvasDeep.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.42, 0.58, 0.78, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
