import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import '../../../../../common/shimmer_component.dart';
import '../../../floating dev id.dart';

class PodVideoPlayerDev extends StatefulWidget {
  final String type;
  final String url;
  final RouteObserver<ModalRoute<void>> routeObserver;

  const PodVideoPlayerDev(this.url, this.type, this.routeObserver, {super.key});

  @override
  State<PodVideoPlayerDev> createState() => _PodVideoPlayerDevState();
}

class _PodVideoPlayerDevState extends State<PodVideoPlayerDev> with RouteAware {
  late final PodPlayerController controller;
  bool isVisible = true; // Control visibility of the FloatingDeviceInfoWidget
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();

    // Initialize the controller based on the video type
    controller = PodPlayerController(
      playVideoFrom: widget.type == 'vimeo'
          ? PlayVideoFrom.vimeo(widget.url)
          : PlayVideoFrom.network(widget.url),
      podPlayerConfig: const PodPlayerConfig(
        isLooping: false,
      ),
    );

    controller.initialise().then((_) {
      setState(() {
        isLoading = false; // Video is ready
      });
    });
    controller.addListener(_fullscreenListener);
  }

  @override
  void dispose() {
    controller.removeListener(_fullscreenListener);
    controller.dispose();
    super.dispose();
  }

  // Fullscreen listener to toggle visibility of FloatingDeviceInfoWidget
  void _fullscreenListener() {
    if (mounted) {
      setState(() {
        // Show the floating widget only if not in fullscreen
        isVisible = !controller.isFullScreen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          if (isLoading)
            videoImageShimmer()
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: PodVideoPlayer(controller: controller),
              ),
            ),
          if (isVisible)
            FloatingDeviceInfoWidget(), // Show only if not in fullscreen
        ],
      ),
    );
  }
}
