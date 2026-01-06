import 'dart:io';
import 'package:flutter/material.dart';

class ImageGalleryWidget extends StatelessWidget {
  final List<String> networkImages;
  final List<File> localImages;
  final Function(int, bool)? onRemove; // (index, isLocal)
  final VoidCallback? onAddMore;
  final bool showAddButton;
  final bool showRemoveButtons;

  const ImageGalleryWidget({
    super.key,
    this.networkImages = const [],
    this.localImages = const [],
    this.onRemove,
    this.onAddMore,
    this.showAddButton = true,
    this.showRemoveButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final totalImages = networkImages.length + localImages.length;
    
    if (totalImages == 0) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (networkImages.isNotEmpty) ...[
          const Text(
            'Current Images:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildImageGrid(networkImages, false),
          if (localImages.isNotEmpty) const SizedBox(height: 16),
        ],
        if (localImages.isNotEmpty) ...[
          const Text(
            'New Images:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildImageGrid(localImages.map((f) => f.path).toList(), true),
        ],
        if (showAddButton && totalImages > 0) ...[
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Add Property Images',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to select multiple images',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        if (showAddButton) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddMore,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Select Images'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageGrid(List<String> imagePaths, bool isLocal) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return _buildImageTile(imagePaths[index], index, isLocal);
      },
    );
  }

  Widget _buildImageTile(String imagePath, int index, bool isLocal) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          clipBehavior: Clip.antiAlias,
          child: isLocal
              ? Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
        ),
        if (showRemoveButtons)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => onRemove?.call(index, isLocal),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddMore,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add More'),
          ),
        ),
      ],
    );
  }
}