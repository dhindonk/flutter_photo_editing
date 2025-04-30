import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';

class ImagePreview extends StatefulWidget {
  final Uint8List? originalImage;
  final Uint8List? processedImage;
  final bool isProcessing;

  const ImagePreview({
    super.key,
    required this.originalImage,
    this.processedImage,
    this.isProcessing = false,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  // Value for the divider position, from 0.0 to 1.0
  double _dividerPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.6,
      width: screenWidth,
      child: Column(
        children: [
          // Header row with labels
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Image Preview',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Image comparison area
          Expanded(
            child: _buildImageComparisonView(screenWidth, screenHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildImageComparisonView(double screenWidth, double screenHeight) {
    if (widget.originalImage == null) {
      return const Center(
        child: Text('No image selected'),
      );
    }

    if (widget.isProcessing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Display only original image if no processed image exists
    if (widget.processedImage == null) {
      return Center(
        child: Image.memory(
          widget.originalImage!,
          fit: BoxFit.contain,
        ),
      );
    }

    // When both images are available, show the comparison slider
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final dividerXPosition = width * _dividerPosition;

        return Stack(
          children: [
            // Center images for proper alignment
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Processed image (visible on the right side)
                  Image.memory(
                    widget.processedImage!,
                    fit: BoxFit.contain,
                  ),

                  // Original image (left side with clipper)
                  ClipPath(
                    clipper: ImageSplitClipper(_dividerPosition),
                    child: Image.memory(
                      widget.originalImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // Full-width gesture detector
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dividerPosition += details.delta.dx / width;
                  if (_dividerPosition < 0.0) _dividerPosition = 0.0;
                  if (_dividerPosition > 1.0) _dividerPosition = 1.0;
                });
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Divider line (visual element only, not for dragging)
            Positioned(
              top: 0,
              bottom: 0,
              left: dividerXPosition - 1,
              child: Container(
                width: 2,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.drag_indicator,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Labels for before/after
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Original',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Result',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom clipper that only shows the left portion of the image
class ImageSplitClipper extends CustomClipper<Path> {
  final double position; // Position from 0.0 to 1.0

  ImageSplitClipper(this.position);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTRB(0, 0, size.width * position, size.height));
    return path;
  }

  @override
  bool shouldReclip(ImageSplitClipper oldClipper) =>
      position != oldClipper.position;
}
