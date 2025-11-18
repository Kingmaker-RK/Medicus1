import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AnatomyViewer extends StatefulWidget {
  final List<String> imageUrls;

  const AnatomyViewer({
    Key? key,
    required this.imageUrls,
  }) : super(key: key);

  @override
  State<AnatomyViewer> createState() => _AnatomyViewerState();
}

class _AnatomyViewerState extends State<AnatomyViewer> {
  int _currentIndex = 0;
  bool _is3DView = false;

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
            Icon(
              Icons.view_in_ar,
              size: 60,
              color: AppColors.primary,
            ),
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
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rotate • Zoom • Explore',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
