import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/filter_info_card.dart';
import 'package:flutter_edit_photo_app/widgets/image_preview.dart';
import 'package:provider/provider.dart';

class EdgeDetectionScreen extends StatefulWidget {
  const EdgeDetectionScreen({super.key});

  @override
  State<EdgeDetectionScreen> createState() => _EdgeDetectionScreenState();
}

class _EdgeDetectionScreenState extends State<EdgeDetectionScreen> {
  String? _processingButton;
  final scrollController = ScrollController();

  // Method untuk menangani proses dengan loading indicator pada button
  Future<void> _processWithLoading(
      String buttonId, Future<void> Function() process) async {
    setState(() {
      _processingButton = buttonId;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
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
        title: const Text('Deteksi Tepi'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Cards
              const FilterInfoCard(filterType: 'sobel'),
              const FilterInfoCard(filterType: 'prewitt'),

              const SizedBox(height: 16),

              // Image Preview
              ImagePreview(
                originalImage: imageProvider.currentImage?.originalBytes,
                processedImage: imageProvider.currentImage?.processedBytes,
                isProcessing: imageProvider.isProcessing,
              ),

              const SizedBox(height: 24),

              // Edge Detection Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Algoritma Deteksi Tepi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pilih algoritma deteksi tepi untuk diterapkan:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sobel Button
                      ElevatedButton.icon(
                        onPressed: () => _processWithLoading('sobel', () async {
                          await imageProvider.applySobel();
                        }),
                        icon: _processingButton == 'sobel'
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.line_style),
                        label: Text(_processingButton == 'sobel'
                            ? 'Memproses...'
                            : 'Sobel Edge Detection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _processingButton == 'sobel'
                              ? AppTheme.lightColor
                              : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Prewitt Button
                      ElevatedButton.icon(
                        onPressed: () =>
                            _processWithLoading('prewitt', () async {
                          await imageProvider.applyPrewitt();
                        }),
                        icon: _processingButton == 'prewitt'
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.timeline),
                        label: Text(_processingButton == 'prewitt'
                            ? 'Memproses...'
                            : 'Prewitt Edge Detection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _processingButton == 'prewitt'
                              ? AppTheme.lightColor
                              : AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Comparison Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Perbandingan Algoritma',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Simple comparison table
                      Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        children: const [
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppTheme.lightColor,
                            ),
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Algoritma',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Kelebihan',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Kelemahan',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Sobel'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Lebih tahan terhadap noise karena pembobotan tengah yang lebih besar'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Tepi diagonal kurang terdeteksi dengan baik'),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Prewitt'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Lebih baik untuk tepi vertikal dan horizontal dengan intensitas rata'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Lebih sensitif terhadap noise'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Catatan: Sebaiknya konversi gambar ke grayscale terlebih dahulu sebelum menerapkan deteksi tepi untuk hasil yang lebih baik.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
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
    );
  }
}
