import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeBottomSheet extends StatefulWidget {
  final String youtubeUrl;

  const YouTubeBottomSheet({super.key, required this.youtubeUrl});

  @override
  State<YouTubeBottomSheet> createState() => _YouTubeBottomSheetState();
}

class _YouTubeBottomSheetState extends State<YouTubeBottomSheet> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableJavaScript: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _closeSheet() {
    _controller.pauseVideo();    // stop audio
    Navigator.of(context).pop(); // close sheet
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: [
          YoutubePlayerScaffold(
            controller: _controller,
            aspectRatio: 16 / 9,
            builder: (context, player) {
              return Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: player,
                ),
              );
            },
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _closeSheet,
            ),
          ),
        ],
      ),
    );
  }
}
