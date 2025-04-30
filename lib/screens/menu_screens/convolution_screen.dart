import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/filter_info_card.dart';
import 'package:flutter_edit_photo_app/widgets/image_preview.dart';
import 'package:flutter_edit_photo_app/widgets/slider_parameter.dart';
import 'package:provider/provider.dart';

class ConvolutionScreen extends StatefulWidget {
  const ConvolutionScreen({super.key});

  @override
  State<ConvolutionScreen> createState() => _ConvolutionScreenState();
}

class _ConvolutionScreenState extends State<ConvolutionScreen> {
  double _kernelSize = 3;
  List<List<double>> _customKernel =
      List.generate(3, (_) => List.generate(3, (_) => 0));
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
  void initState() {
    super.initState();
    // Default kernel: Mean filter
    _customKernel = [
      [1 / 9, 1 / 9, 1 / 9],
      [1 / 9, 1 / 9, 1 / 9],
      [1 / 9, 1 / 9, 1 / 9]
    ];
  }

  void _updateKernelSize(double size) {
    // Pastikan size hanya menggunakan nilai 3, 5, atau 7
    int newSize;
    if (size < 4) {
      newSize = 3;
    } else if (size < 6) {
      newSize = 5;
    } else {
      newSize = 7;
    }

    if (newSize != _kernelSize.toInt()) {
      setState(() {
        _kernelSize = newSize.toDouble();

        // Create a properly sized kernel with default values
        _customKernel = List.generate(
          newSize,
          (_) => List.generate(newSize, (_) => 0.0),
        );

        // Set default values for common kernels
        if (newSize == 3) {
          // Mean filter kernel for 3x3
          for (var i = 0; i < 3; i++) {
            for (var j = 0; j < 3; j++) {
              _customKernel[i][j] = 1 / 9;
            }
          }
        } else if (newSize == 5) {
          // Mean filter kernel for 5x5
          for (var i = 0; i < 5; i++) {
            for (var j = 0; j < 5; j++) {
              _customKernel[i][j] = 1 / 25;
            }
          }
        } else if (newSize == 7) {
          // Mean filter kernel for 7x7
          for (var i = 0; i < 7; i++) {
            for (var j = 0; j < 7; j++) {
              _customKernel[i][j] = 1 / 49;
            }
          }
        }
      });
    }
  }

  void _applyPresetKernel(String preset) {
    setState(() {
      switch (preset) {
        case 'Mean':
          _kernelSize = 3.0;
          _customKernel = [
            [1 / 9, 1 / 9, 1 / 9],
            [1 / 9, 1 / 9, 1 / 9],
            [1 / 9, 1 / 9, 1 / 9]
          ];
          break;
        case 'Sharpen':
          _kernelSize = 3.0;
          _customKernel = [
            [0, -1, 0],
            [-1, 5, -1],
            [0, -1, 0]
          ];
          break;
        case 'Gaussian':
          _kernelSize = 3.0;
          _customKernel = [
            [1 / 16, 2 / 16, 1 / 16],
            [2 / 16, 4 / 16, 2 / 16],
            [1 / 16, 2 / 16, 1 / 16]
          ];
          break;
        case 'Laplacian':
          _kernelSize = 3.0;
          _customKernel = [
            [0, 1, 0],
            [1, -4, 1],
            [0, 1, 0]
          ];
          break;
      }
      // Debug: Verifikasi kernel yang diset
      print('Set kernel to $preset:');
      for (var row in _customKernel) {
        print(row);
      }
    });
  }

  // Fungsi untuk langsung mengaplikasikan preset
  void _applyPresetDirectly(String preset, ImageEditorProvider imageProvider) {
    // Tentukan kernel berdasarkan preset
    List<List<double>> kernel;

    switch (preset) {
      case 'Mean':
        kernel = [
          [1 / 9, 1 / 9, 1 / 9],
          [1 / 9, 1 / 9, 1 / 9],
          [1 / 9, 1 / 9, 1 / 9]
        ];
        break;
      case 'Sharpen':
        kernel = [
          [0, -1, 0],
          [-1, 5, -1],
          [0, -1, 0]
        ];
        break;
      case 'Gaussian':
        kernel = [
          [1 / 16, 2 / 16, 1 / 16],
          [2 / 16, 4 / 16, 2 / 16],
          [1 / 16, 2 / 16, 1 / 16]
        ];
        break;
      case 'Laplacian':
        kernel = [
          [0, 1, 0],
          [1, -4, 1],
          [0, 1, 0]
        ];
        break;
      default:
        kernel = [
          [1 / 9, 1 / 9, 1 / 9],
          [1 / 9, 1 / 9, 1 / 9],
          [1 / 9, 1 / 9, 1 / 9]
        ];
    }

    // Langsung terapkan konvolusi
    _processWithLoading('preset_$preset', () async {
      print('Directly applying $preset preset with kernel:');
      for (var row in kernel) {
        print(row);
      }
      await imageProvider.applyConvolution(kernel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageEditorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konvolusi & Ketetanggaan'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Cards
              const FilterInfoCard(filterType: 'mean_filter'),
              const FilterInfoCard(filterType: 'median_filter'),
              const FilterInfoCard(filterType: 'convolution'),

              const SizedBox(height: 16),

              // Image Preview
              ImagePreview(
                originalImage: imageProvider.currentImage?.originalBytes,
                processedImage: imageProvider.currentImage?.processedBytes,
                isProcessing: imageProvider.isProcessing,
              ),

              const SizedBox(height: 24),

              // Mean & Median Filters Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Filter Ketetanggaan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Kernel Size Slider for Mean Filter
                    SliderParameter(
                      label: 'Ukuran Kernel',
                      value: _kernelSize,
                      min: 3,
                      max: 7,
                      divisions: 2, // Hanya 3 nilai: 3, 5, 7
                      valueLabel:
                          '${_kernelSize.toInt()}x${_kernelSize.toInt()}',
                      onChanged: (value) {
                        _updateKernelSize(value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Filter Buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _processWithLoading('mean', () async {
                                await imageProvider
                                    .applyMeanFilter(_kernelSize.toInt());
                              }),
                              icon: _processingButton == 'mean'
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      padding: const EdgeInsets.all(2.0),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.blur_on),
                              label: Text(_processingButton == 'mean'
                                  ? 'Memproses...'
                                  : 'Mean Filter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _processingButton == 'mean'
                                    ? Colors.grey
                                    : AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _processWithLoading('median', () async {
                                await imageProvider
                                    .applyMedianFilter(_kernelSize.toInt());
                              }),
                              icon: _processingButton == 'median'
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
                              label: Text(_processingButton == 'median'
                                  ? 'Memproses...'
                                  : 'Median Filter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _processingButton == 'median'
                                    ? Colors.grey
                                    : AppTheme.accentColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Custom Convolution Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Konvolusi Kustom',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kernel Size Selector
                      Row(
                        children: [
                          const Text('Ukuran Kernel: '),
                          const SizedBox(width: 16),
                          DropdownButton<int>(
                            value: _kernelSize.toInt(),
                            items: const [
                              DropdownMenuItem(
                                value: 3,
                                child: Text('3x3'),
                              ),
                              DropdownMenuItem(
                                value: 5,
                                child: Text('5x5'),
                              ),
                              DropdownMenuItem(
                                value: 7,
                                child: Text('7x7'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _updateKernelSize(value.toDouble());
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Custom Kernel Matrix
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Kernel Matrix',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Matrix UI - Wrapped in SingleChildScrollView to prevent overflow
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  for (int i = 0; i < _customKernel.length; i++)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (int j = 0;
                                            j < _customKernel[i].length;
                                            j++)
                                          Container(
                                            width: 50,
                                            height: 50,
                                            margin: const EdgeInsets.all(2),
                                            child: TextFormField(
                                              key: Key(
                                                  'kernel_${i}_${j}_${_kernelSize.toInt()}'),
                                              initialValue: _customKernel[i][j]
                                                  .toStringAsFixed(2),
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true, signed: true),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 4),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                try {
                                                  final newValue =
                                                      double.parse(value);
                                                  setState(() {
                                                    _customKernel[i][j] =
                                                        newValue;
                                                  });
                                                } catch (e) {
                                                  // Invalid input
                                                }
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: () =>
                            _processWithLoading('custom', () async {
                          await imageProvider.applyConvolution(_customKernel);
                        }),
                        icon: _processingButton == 'custom'
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.filter_tilt_shift),
                        label: Text(_processingButton == 'custom'
                            ? 'Memproses...'
                            : 'Apply Custom Convolution'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _processingButton == 'custom'
                              ? Colors.grey
                              : AppTheme.darkColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildPresetButton(String label, ImageEditorProvider imageProvider) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          // Update UI dengan preset kernel
          _applyPresetKernel(label);

          // Langsung terapkan preset
          _applyPresetDirectly(label, imageProvider);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightColor,
          foregroundColor: AppTheme.textColor,
        ),
        child: Text(label),
      ),
    );
  }
}
