import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/nasa_image.dart';
import '../services/starred_service.dart';

class ImageDetails extends StatefulWidget {
  final NasaImage image;
  final VoidCallback? onStarChanged;

  const ImageDetails({super.key, required this.image, this.onStarChanged});

  @override
  State<ImageDetails> createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {
  final _starredService = StarredService();
  bool _isStarred = false;

  @override
  void initState() {
    super.initState();
    _loadStarState();
  }

  Future<void> _loadStarState() async {
    final starred = await _starredService.isStarred(widget.image);
    if (mounted) {
      setState(() => _isStarred = starred);
    }
  }

  Future<void> _toggleStar() async {
    HapticFeedback.lightImpact();

    final newState = await _starredService.toggle(widget.image);

    if (!mounted) return;

    setState(() => _isStarred = newState);

    widget.onStarChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleStar,
                      icon: Icon(
                        _isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: _isStarred ? Colors.amber : Colors.white70,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                // ───────── Scrollable content ─────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              widget.image.previewUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.black12,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          widget.image.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          widget.image.description ??
                              'No description available.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
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
}
