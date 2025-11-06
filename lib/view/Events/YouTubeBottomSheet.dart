import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeBottomSheet extends StatefulWidget {
  final String youtubeUrl;

  const YouTubeBottomSheet({super.key, required this.youtubeUrl});

  @override
  State<YouTubeBottomSheet> createState() => _YouTubeBottomSheetState();
}

class _YouTubeBottomSheetState extends State<YouTubeBottomSheet> {
  YoutubePlayerController? _controller;
  String? _errorMessage;
  bool _isPlayerReady = false;

  /// Extracts YouTube video ID from various URL formats including live URLs
  String? _extractVideoId(String url) {
    if (url.isEmpty) return null;

    // Clean the URL first
    String cleanUrl = url.trim();
    
    // Handle live URLs: https://www.youtube.com/live/VIDEO_ID?si=...
    if (cleanUrl.contains('/live/')) {
      final liveMatch = RegExp(r'/live/([a-zA-Z0-9_-]+)').firstMatch(cleanUrl);
      if (liveMatch != null && liveMatch.groupCount >= 1) {
        String? videoId = liveMatch.group(1);
        if (videoId != null && videoId.isNotEmpty) {
          videoId = videoId.split('?').first.split('&').first.split('#').first;
          if (videoId.length >= 11) {
            return videoId;
          }
        }
      }
    }

    // Handle watch URLs: https://www.youtube.com/watch?v=VIDEO_ID
    if (cleanUrl.contains('watch?v=')) {
      final watchMatch = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(cleanUrl);
      if (watchMatch != null && watchMatch.groupCount >= 1) {
        return watchMatch.group(1);
      }
    }

    // Handle short URLs: https://youtu.be/VIDEO_ID
    if (cleanUrl.contains('youtu.be/')) {
      final shortMatch = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)').firstMatch(cleanUrl);
      if (shortMatch != null && shortMatch.groupCount >= 1) {
        String? videoId = shortMatch.group(1);
        if (videoId != null) {
          videoId = videoId.split('?').first.split('&').first.split('#').first;
          if (videoId.length >= 11) {
            return videoId;
          }
        }
      }
    }

    // Handle embed URLs: https://www.youtube.com/embed/VIDEO_ID
    if (cleanUrl.contains('/embed/')) {
      final embedMatch = RegExp(r'/embed/([a-zA-Z0-9_-]+)').firstMatch(cleanUrl);
      if (embedMatch != null && embedMatch.groupCount >= 1) {
        String? videoId = embedMatch.group(1);
        if (videoId != null) {
          videoId = videoId.split('?').first.split('&').first.split('#').first;
          if (videoId.length >= 11) {
            return videoId;
          }
        }
      }
    }

    // Fallback: If URL is just a video ID (11 characters)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(cleanUrl)) {
      return cleanUrl;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// Checks if URL is a live stream
  bool _isLiveStream(String url) {
    return url.toLowerCase().contains('/live/');
  }

  void _initializePlayer() {
    final videoId = _extractVideoId(widget.youtubeUrl);
    
    debugPrint('YouTube URL: ${widget.youtubeUrl}');
    debugPrint('Extracted Video ID: $videoId');

    if (videoId == null || videoId.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Invalid YouTube URL. Could not extract video ID. Please check the video link.';
        });
      }
      return;
    }

    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableJavaScript: true,
          playsInline: true,
          mute: false,
          loop: false,
        ),
      );

      // Listen to player state changes
      _controller!.listen((event) {
        debugPrint('YouTube player event: $event');
        
        // Check if player is ready
        if (event.toString().contains('ready') || event.toString().contains('playing')) {
          if (!_isPlayerReady && mounted) {
            setState(() {
              _isPlayerReady = true;
            });
            debugPrint('YouTube player is ready!');
          }
        }
        
        // Check for errors
        if (event.toString().toLowerCase().contains('error') ||
            event.toString().toLowerCase().contains('unavailable')) {
          debugPrint('YouTube player error detected');
          if (mounted && _errorMessage == null) {
            setState(() {
              final isLive = _isLiveStream(widget.youtubeUrl);
              if (isLive) {
                _errorMessage = 'This live stream cannot be played. Live streams often have embedding restrictions. Please use "Open in Browser" to watch.';
              } else {
                _errorMessage = 'Video cannot be played. The video may have embedding restrictions.';
              }
            });
          }
        }
      });

      if (mounted) {
        setState(() {
          // Controller initialized
        });
      }
    } catch (e) {
      debugPrint('Error initializing YouTube player: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize video player. Please try opening the video in your browser.';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _closeSheet() {
    _controller?.pauseVideo();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Video ID: ${_extractVideoId(widget.youtubeUrl) ?? "N/A"}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'URL: ${widget.youtubeUrl}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = widget.youtubeUrl;
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open in Browser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_controller != null)
            YoutubePlayerScaffold(
              controller: _controller!,
              aspectRatio: 16 / 9,
              builder: (context, player) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: player,
                  ),
                );
              },
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _closeSheet,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
