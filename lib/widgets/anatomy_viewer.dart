import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
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
  bool _showDemoModel = false;

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
                      // Reset demo state when toggling
                      if (!_is3DView) _showDemoModel = false;
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
                  _showDemoModel = false; // Reset demo model when changing images
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
                          : AppColors.textSecondary.withValues(alpha: 0.3),
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
                  color: AppColors.primary.withValues(alpha: 0.5),
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
    // In a production environment, we would map specific anatomy parts to their corresponding 3D models.
    // Since we currently rely on 2D image URLs, we will use a high-quality 3D model placeholder
    // to demonstrate the viewer's capabilities if the URL is not a 3D file.
    // Using BrainStem model as a more appropriate medical example than the default astronaut.
    const String sampleModelUrl = 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/BrainStem/glTF-Binary/BrainStem.glb';
    
    final bool isLikely3D = modelUrl.toLowerCase().endsWith('.glb') || modelUrl.toLowerCase().endsWith('.gltf');

    // If it's not a 3D model and user hasn't requested the demo yet
    if (!isLikely3D && !_showDemoModel) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.threed_rotation, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'No specific 3D model for this organ',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showDemoModel = true;
                  });
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.visibility), 
                label: const Text('View Demo 3D Model'),
              ),
            ],
          ),
        ),
      );
    }

    final String urlToLoad = isLikely3D ? modelUrl : sampleModelUrl;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.shadow.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            ModelViewer(
              src: urlToLoad,
              alt: 'Anatomy 3D Model',
              ar: true,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.transparent,
              loading: Loading.eager,
              poster: 'https://via.placeholder.com/400x300.png?text=Loading+3D+Model',
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.threed_rotation, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        isLikely3D ? 'Interactive 3D View' : 'Demo 3D Model (Brain Stem)',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
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
  bool _showDemoModel = false;
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
        backgroundColor: Colors.black.withValues(alpha: 0.5),
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
                if (!_is3DView) _showDemoModel = false;
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
                _showDemoModel = false;
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
                          : Colors.white.withValues(alpha: 0.4),
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
                color: Colors.white.withValues(alpha: 0.5),
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
    // Same implementation for fullscreen, but with dark background
    const String sampleModelUrl = 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/BrainStem/glTF-Binary/BrainStem.glb';
    
    final bool isLikely3D = modelUrl.toLowerCase().endsWith('.glb') || modelUrl.toLowerCase().endsWith('.gltf');

    // If it's not a 3D model and user hasn't requested the demo yet
    if (!isLikely3D && !_showDemoModel) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.threed_rotation, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'No specific 3D model for this organ',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showDemoModel = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.visibility),
                label: const Text('View Demo 3D Model'),
              ),
            ],
          ),
        ),
      );
    }

    final String urlToLoad = isLikely3D ? modelUrl : sampleModelUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            ModelViewer(
              src: urlToLoad,
              alt: 'Anatomy 3D Model',
              ar: true,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.transparent,
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.threed_rotation, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        isLikely3D ? 'Interactive 3D View' : 'Demo 3D Model (Brain Stem)',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}