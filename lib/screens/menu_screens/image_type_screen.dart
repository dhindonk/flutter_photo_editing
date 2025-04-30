import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/filter_info_card.dart';
import 'package:flutter_edit_photo_app/widgets/image_preview.dart';
import 'package:flutter_edit_photo_app/widgets/slider_parameter.dart';
import 'package:provider/provider.dart';

class ImageTypeScreen extends StatefulWidget {
  const ImageTypeScreen({super.key});

  @override
  State<ImageTypeScreen> createState() => _ImageTypeScreenState();
}

class _ImageTypeScreenState extends State<ImageTypeScreen> {
  double _threshold = 128;
  String? _processingButton;
  final scrollController = ScrollController();

  // Method untuk menangani proses dengan loading indicator pada button
  Future<void> _processWithLoading(
      String buttonId, Future<void> Function() process) async {
    setState(() {
      _processingButton = buttonId;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      await process();
    } finally {
      if (mounted) {
        setState(() {
          _processingButton = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageEditorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jenis Citra'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Teori Info Card
              const FilterInfoCard(filterType: 'grayscale'),
              const FilterInfoCard(filterType: 'binary'),

              const SizedBox(height: 16),

              // Image Preview
              ImagePreview(
                originalImage: imageProvider.currentImage?.originalBytes,
                processedImage: imageProvider.currentImage?.processedBytes,
                isProcessing: imageProvider.isProcessing,
              ),

              const SizedBox(height: 24),

              // Controls
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Konversi Jenis Citra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grayscale Button
                    ElevatedButton.icon(
                      onPressed: () =>
                          _processWithLoading('grayscale', () async {
                        await imageProvider.applyGrayscale();
                      }),
                      icon: _processingButton == 'grayscale'
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.image),
                      label: Text(_processingButton == 'grayscale'
                          ? 'Memproses...'
                          : 'Konversi ke Grayscale'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _processingButton == 'grayscale'
                            ? Colors.grey
                            : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Binary Threshold
                    const Text(
                      'Binerisasi dengan Threshold',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    SliderParameter(
                      label: 'Threshold',
                      value: _threshold,
                      min: 0,
                      max: 255,
                      divisions: 255,
                      valueLabel: _threshold.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _threshold = value;
                        });
                      },
                    ),

                    ElevatedButton.icon(
                      onPressed: () => _processWithLoading('binary', () async {
                        await imageProvider.applyBinary(
                            threshold: _threshold.toInt());
                      }),
                      icon: _processingButton == 'binary'
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.contrast),
                      label: Text(_processingButton == 'binary'
                          ? 'Memproses...'
                          : 'Konversi ke Biner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _processingButton == 'binary'
                            ? Colors.grey
                            : AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
