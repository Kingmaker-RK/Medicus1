import 'package:flutter/material.dart';
import 'translated_widget.dart';
import '../constants/colors.dart';

class AnatomyViewer extends StatefulWidget {
  final List<String> imageUrls;

  const AnatomyViewer({Key? key, required this.imageUrls}) : super(key: key);

  @override
  State<AnatomyViewer> createState() => _AnatomyViewerState();
}

class _AnatomyViewerState extends State<AnatomyViewer> {
  int _currentIndex = 0;
  bool _is3DView = false;

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullscreenAnatomyViewer(
          imageUrls: widget.imageUrls,
          initialIndex: _currentIndex,
          is3DView: _is3DView,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Center(
        child: Text(
          'No anatomy images available',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Anatomy Reference',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.fullscreen, size: 20),
                  onPressed: () => _openFullscreen(context),
                  tooltip: 'Fullscreen',
                ),
                IconButton(
                  icon: Icon(
                    _is3DView ? Icons.view_in_ar : Icons.image,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _is3DView = !_is3DView;
                    });
                  },
                  tooltip: _is3DView ? 'Switch to 2D' : 'Switch to 3D',
                ),
              ],
            ),
          ),

          // Image viewer
          Expanded(
            child: PageView.builder(
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _is3DView
                      ? _build3DView(widget.imageUrls[index])
                      : _build2DView(widget.imageUrls[index]),
                );
              },
            ),
          ),

          // Page indicator
          if (widget.imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _build2DView(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services,
                  size: 60,
                  color: AppColors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anatomy Image',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _build3DView(String modelUrl) {
    // TODO: Integrate with model_viewer_plus for actual 3D rendering
    // For now, showing a placeholder
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              '3D Model View',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive 3D anatomy model',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Rotate • Zoom • Explore',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// Fullscreen anatomy viewer
class _FullscreenAnatomyViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final bool is3DView;

  const _FullscreenAnatomyViewer({
    required this.imageUrls,
    required this.initialIndex,
    required this.is3DView,
  });

  @override
  State<_FullscreenAnatomyViewer> createState() =>
      _FullscreenAnatomyViewerState();
}

class _FullscreenAnatomyViewerState extends State<_FullscreenAnatomyViewer> {
  late int _currentIndex;
  late bool _is3DView;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _is3DView = widget.is3DView;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Anatomy Reference ${_currentIndex + 1}/${widget.imageUrls.length}',
        ),
        actions: [
          IconButton(
            icon: Icon(_is3DView ? Icons.view_in_ar : Icons.image),
            onPressed: () {
              setState(() {
                _is3DView = !_is3DView;
              });
            },
            tooltip: _is3DView ? 'Switch to 2D' : 'Switch to 3D',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: AutoTranslateText('Download functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Download image',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: AutoTranslateText('Share functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image viewer
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: _is3DView
                      ? _build3DView(widget.imageUrls[index])
                      : _build2DView(widget.imageUrls[index]),
                ),
              );
            },
          ),

          // Navigation arrows
          if (widget.imageUrls.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 48,
                    color: Colors.white,
                  ),
                  onPressed: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    size: 48,
                    color: Colors.white,
                  ),
                  onPressed: _currentIndex < widget.imageUrls.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],

          // Page indicator
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _build2DView(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Anatomy Image',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DView(String modelUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar, size: 80, color: AppColors.accent),
            const SizedBox(height: 24),
            const Text(
              '3D Model View',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Interactive 3D anatomy model',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rotate • Zoom • Explore',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
