import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/filter_info_card.dart';
import 'package:flutter_edit_photo_app/widgets/image_preview.dart';
import 'package:flutter_edit_photo_app/widgets/slider_parameter.dart';
import 'package:provider/provider.dart';

class MorphologyScreen extends StatefulWidget {
  const MorphologyScreen({super.key});

  @override
  State<MorphologyScreen> createState() => _MorphologyScreenState();
}

class _MorphologyScreenState extends State<MorphologyScreen> {
  double _iterations = 1;
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
        title: const Text('Morfologi Citra'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Cards
              const FilterInfoCard(filterType: 'erosion'),
              const FilterInfoCard(filterType: 'dilation'),
              const FilterInfoCard(filterType: 'opening'),
              const FilterInfoCard(filterType: 'closing'),

              const SizedBox(height: 16),

              // Image Preview
              ImagePreview(
                originalImage: imageProvider.currentImage?.originalBytes,
                processedImage: imageProvider.currentImage?.processedBytes,
                isProcessing: imageProvider.isProcessing,
              ),

              const SizedBox(height: 24),

              // Operations Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Operasi Morfologi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Iterations Slider
                    SliderParameter(
                      label: 'Jumlah Iterasi',
                      value: _iterations,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      valueLabel: _iterations.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _iterations = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Row for Erosion and Dilation
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _processWithLoading('erosion', () async {
                              await Future(() => imageProvider
                                  .applyErosion(_iterations.toInt()));
                            }),
                            icon: _processingButton == 'erosion'
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.remove_circle_outline),
                            label: Text(_processingButton == 'erosion'
                                ? 'Memproses...'
                                : 'Erosi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _processingButton == 'erosion'
                                  ? AppTheme.lightColor
                                  : AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _processWithLoading('dilation', () async {
                              await Future(() => imageProvider
                                  .applyDilation(_iterations.toInt()));
                            }),
                            icon: _processingButton == 'dilation'
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_circle_outline),
                            label: Text(_processingButton == 'dilation'
                                ? 'Memproses...'
                                : 'Dilasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _processingButton == 'dilation'
                                  ? AppTheme.lightColor
                                  : AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Row for Opening and Closing
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _processWithLoading('opening', () async {
                              await Future(() => imageProvider
                                  .applyOpening(_iterations.toInt()));
                            }),
                            icon: _processingButton == 'opening'
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.healing),
                            label: Text(_processingButton == 'opening'
                                ? 'Memproses...'
                                : 'Opening'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _processingButton == 'opening'
                                  ? AppTheme.lightColor
                                  : AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _processWithLoading('closing', () async {
                              await Future(() => imageProvider
                                  .applyClosing(_iterations.toInt()));
                            }),
                            icon: _processingButton == 'closing'
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.blur_circular),
                            label: Text(_processingButton == 'closing'
                                ? 'Memproses...'
                                : 'Closing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _processingButton == 'closing'
                                  ? AppTheme.lightColor
                                  : Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Visual Explanation Card
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Penjelasan Visual',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Simplified visual representation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildVisualWidget(
                            'Erosi',
                            Icons.remove_circle_outline,
                            AppTheme.primaryColor,
                            'Mengecilkan objek, menghilangkan detail kecil',
                          ),
                          _buildVisualWidget(
                            'Dilasi',
                            Icons.add_circle_outline,
                            AppTheme.accentColor,
                            'Memperbesar objek, mengisi lubang kecil',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildVisualWidget(
                            'Opening',
                            Icons.healing,
                            AppTheme.darkColor,
                            'Erosi → Dilasi\nMenghilangkan objek kecil, mempertahankan bentuk',
                          ),
                          _buildVisualWidget(
                            'Closing',
                            Icons.blur_circular,
                            Colors.deepPurple,
                            'Dilasi → Erosi\nMenutup lubang kecil, mempertahankan bentuk',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualWidget(
      String title, IconData icon, Color color, String description) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 48,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
