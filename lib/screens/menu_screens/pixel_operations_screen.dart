import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/filter_info_card.dart';
import 'package:flutter_edit_photo_app/widgets/image_preview.dart';
import 'package:flutter_edit_photo_app/widgets/slider_parameter.dart';
import 'package:provider/provider.dart';

class PixelOperationsScreen extends StatefulWidget {
  const PixelOperationsScreen({super.key});

  @override
  State<PixelOperationsScreen> createState() => _PixelOperationsScreenState();
}

class _PixelOperationsScreenState extends State<PixelOperationsScreen> {
  double _brightness = 0;
  double _contrast = 0;
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
        title: const Text('Operasi Pixel & Histogram'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Cards
              const FilterInfoCard(filterType: 'brightness'),
              const FilterInfoCard(filterType: 'contrast'),
              const FilterInfoCard(filterType: 'histogram_equalization'),

              const SizedBox(height: 16),

              // Image Preview
              ImagePreview(
                originalImage: imageProvider.currentImage?.originalBytes,
                processedImage: imageProvider.currentImage?.processedBytes,
                isProcessing: imageProvider.isProcessing,
              ),

              const SizedBox(height: 24),

              // Brightness & Contrast Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Brightness & Contrast',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SliderParameter(
                      label: 'Brightness',
                      value: _brightness,
                      min: -100,
                      max: 100,
                      divisions: 200,
                      valueLabel: _brightness.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _brightness = value;
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _processWithLoading('brightness', () async {
                        await imageProvider
                            .adjustBrightness(_brightness.toInt());
                      }),
                      icon: _processingButton == 'brightness'
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.brightness_6),
                      label: Text(_processingButton == 'brightness'
                          ? 'Memproses...'
                          : 'Apply Brightness'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _processingButton == 'brightness'
                            ? Colors.grey
                            : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    SliderParameter(
                      label: 'Contrast',
                      value: _contrast,
                      min: -100,
                      max: 100,
                      divisions: 200,
                      valueLabel: _contrast.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _contrast = value;
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _processWithLoading('contrast', () async {
                        await imageProvider.adjustContrast(_contrast.toInt());
                      }),
                      icon: _processingButton == 'contrast'
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
                      label: Text(_processingButton == 'contrast'
                          ? 'Memproses...'
                          : 'Apply Contrast'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _processingButton == 'contrast'
                            ? Colors.grey
                            : AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Histogram Equalization Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Histogram Equalization',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _processWithLoading('equalize', () async {
                        await imageProvider.equalizeHistogram();
                      }),
                      icon: _processingButton == 'equalize'
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.auto_graph),
                      label: Text(_processingButton == 'equalize'
                          ? 'Memproses...'
                          : 'Apply Histogram Equalization'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _processingButton == 'equalize'
                            ? Colors.grey
                            : AppTheme.darkColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Catatan: Histogram equalization akan meratakan distribusi intensitas pixel untuk meningkatkan kontras citra secara otomatis.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
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
