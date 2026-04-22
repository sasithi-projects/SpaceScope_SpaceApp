import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/nasa_image.dart';
import '../services/image_search_service.dart';
import '../services/starred_service.dart';
import '../widgets/image_details.dart';
import '../widgets/video_details.dart';
import '../widgets/space_background.dart';

class ExplorerScreen extends StatefulWidget {
  final bool resetStarred;

  const ExplorerScreen({super.key, this.resetStarred = false});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final _service = ImageSearchService();
  final _starredService = StarredService();
  final _controller = TextEditingController();

  bool _loading = false;
  bool _isSearchMode = false;
  bool _isStarredMode = false;
  bool _isOffline = false;
  bool _showExternalOpenPill = false;

  String _selectedMediaType = 'image';
  List<NasaImage> _results = [];
  final Map<String, bool> _starredCache = {};

  final List<String> _curatedTopics = [
    'moon',
    'mars',
    'nebula',
    'galaxy',
    'earth',
    'saturn',
  ];

  String _resultsTitle() {
    if (_isStarredMode) {
      return _selectedMediaType == 'image'
          ? 'Starred images'
          : 'Starred videos';
    }

    if (_isSearchMode) {
      final query = _controller.text.trim();
      if (_results.isEmpty) {
        return 'No results found for "$query"';
      }
      return 'Showing Results for "$query"';
    }

    return _selectedMediaType == 'image'
        ? 'Featured images'
        : 'Featured videos';
  }

  @override
  void initState() {
    super.initState();
    if (widget.resetStarred) _isStarredMode = false;
    _loadCurated();
  }

  // ───────────────── Pills ─────────────────

  Widget _offlinePill() {
    if (!_isOffline) return const SizedBox.shrink();

    return Positioned(
      bottom: 90,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 18, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  'You are offline',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _externalOpenPill() {
    if (!_showExternalOpenPill) return const SizedBox.shrink();

    return Positioned(
      bottom: 64,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_in_new, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Opening in an external app…',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── Data loading ─────────────────

  Future<void> _handleRefresh() async {
    _isOffline = false;
    _isStarredMode
        ? await _loadStarred()
        : _isSearchMode
        ? _runSearch()
        : _loadCurated();
  }

  Future<void> _syncStarredState() async {
    for (final item in _results) {
      final id = _starredService.makeId(item);
      _starredCache[id] = await _starredService.isStarred(item);
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadStarred() async {
    setState(() => _loading = true);
    final starred = await _starredService.getAll();
    _results = starred.where((e) => e.mediaType == _selectedMediaType).toList();
    await _syncStarredState();
    setState(() => _loading = false);
  }

  Future<void> _loadCurated() async {
    final topic =
        _curatedTopics[DateTime.now().millisecondsSinceEpoch %
            _curatedTopics.length];

    setState(() {
      _loading = true;
      _isSearchMode = false;
    });

    try {
      _results = await _service.searchImages(
        topic,
        mediaType: _selectedMediaType,
      );
      await _syncStarredState();
    } catch (_) {
      _isOffline = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runSearch() async {
    if (_isStarredMode) return;
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _isSearchMode = true;
    });

    try {
      _results = await _service.searchImages(
        query,
        mediaType: _selectedMediaType,
      );
      await _syncStarredState();
    } catch (_) {
      _isOffline = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  // ───────────────── Video ─────────────────

  Future<void> _openVideoExternally(NasaImage video) async {
    setState(() => _showExternalOpenPill = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _showExternalOpenPill = false);
      }
    });

    final url = await _service.getVideoUrl(video.assetUrl!);
    if (url == null) return;

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // ───────────────── Media tabs ─────────────────

  Widget _buildTab(String label, String type) {
    final active = _selectedMediaType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (active) return;
          HapticFeedback.selectionClick();

          setState(() {
            _selectedMediaType = type;
            _loading = true;
          });

          if (_isStarredMode) {
            await _loadStarred();
          } else if (_isSearchMode) {
            await _runSearch();
          } else {
            await _loadCurated();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final emptyText = _isStarredMode
        ? (_selectedMediaType == 'image'
              ? 'No starred images '
              : 'No starred videos ')
        : _isSearchMode
        ? 'No results found'
        : 'Discover space imagery ✨';

    return Scaffold(
      
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_isStarredMode ? 'Starred' : 'Explore'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.selectionClick();

                setState(() {
                  _isStarredMode = !_isStarredMode;
                  _loading = true;
                });

                _isStarredMode ? await _loadStarred() : await _loadCurated();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isStarredMode
                      ? Colors.amber.withOpacity(0.95)
                      : Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _isStarredMode
                        ? Colors.amberAccent
                        : Colors.white.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isStarredMode
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 18,
                      color: _isStarredMode ? Colors.black : Colors.amberAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Starred',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isStarredMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      body: SpaceBackground(
        child: Stack(
          children: [
            Column(
              children: [
                if (!_isStarredMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _runSearch(),
                      decoration: InputDecoration(
                        hintText: 'Search NASA images',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            _isSearchMode = false;
                            _loadCurated();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Images', 'image'),
                        _buildTab('Videos', 'video'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _resultsTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: _results.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 200),
                                    Center(
                                      child: Text(
                                        emptyText,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.9,
                                      ),
                                  itemCount: _results.length,
                                  itemBuilder: (context, index) {
                                    final img = _results[index];

                                    return GestureDetector(
                                      onTap: () {
                                        img.mediaType == 'image'
                                            ? showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (_) => ImageDetails(
                                                  image: img,
                                                  onStarChanged:
                                                      _syncStarredState,
                                                ),
                                              )
                                            : showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (_) => VideoDetails(
                                                  video: img,
                                                  onOpenExternal: () {
                                                    Navigator.pop(context);
                                                    _openVideoExternally(img);
                                                  },
                                                  onStarChanged:
                                                      _syncStarredState,
                                                ),
                                              );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: CachedNetworkImage(
                                          imageUrl: img.previewUrl ?? '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
            _offlinePill(),
            _externalOpenPill(),
          ],
        ),
      ),
    );
  }
}
