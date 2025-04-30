import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/filter_info_card.dart';
import 'package:flutter_edit_photo_app/widgets/image_preview.dart';
import 'package:flutter_edit_photo_app/widgets/slider_parameter.dart';
import 'package:provider/provider.dart';

class GeometricScreen extends StatefulWidget {
  const GeometricScreen({super.key});

  @override
  State<GeometricScreen> createState() => _GeometricScreenState();
}

class _GeometricScreenState extends State<GeometricScreen> {
  double _translateX = 0;
  double _translateY = 0;
  double _rotationAngle = 0;
  double _scale = 1.0;
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
        title: const Text('Operasi Geometri'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Cards
              const FilterInfoCard(filterType: 'translation'),
              const FilterInfoCard(filterType: 'rotation'),
              const FilterInfoCard(filterType: 'scaling'),

              const SizedBox(height: 16),

              // Image Preview
              ImagePreview(
                originalImage: imageProvider.currentImage?.originalBytes,
                processedImage: imageProvider.currentImage?.processedBytes,
                isProcessing: imageProvider.isProcessing,
              ),

              const SizedBox(height: 24),

              // Translation Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Translasi (Pergeseran)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SliderParameter(
                      label: 'X Axis',
                      value: _translateX,
                      min: -100,
                      max: 100,
                      valueLabel: '${_translateX.toInt()} px',
                      onChanged: (value) {
                        setState(() {
                          _translateX = value;
                        });
                      },
                    ),
                    SliderParameter(
                      label: 'Y Axis',
                      value: _translateY,
                      min: -100,
                      max: 100,
                      valueLabel: '${_translateY.toInt()} px',
                      onChanged: (value) {
                        setState(() {
                          _translateY = value;
                        });
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _processWithLoading('translate', () async {
                        await Future(() => imageProvider.translateImage(
                            _translateX.toInt(), _translateY.toInt()));
                      }),
                      icon: _processingButton == 'translate'
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.open_with),
                      label: Text(_processingButton == 'translate'
                          ? 'Memproses...'
                          : 'Apply Translation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _processingButton == 'translate'
                            ? AppTheme.lightColor
                            : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Rotation Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Rotasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SliderParameter(
                      label: 'Angle',
                      value: _rotationAngle,
                      min: 0,
                      max: 359,
                      divisions: 359,
                      valueLabel: '${_rotationAngle.toInt()}°',
                      onChanged: (value) {
                        setState(() {
                          _rotationAngle = value;
                        });
                      },
                    ),

                    // Quick Rotation Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickRotateButton('90°', 90),
                          _buildQuickRotateButton('180°', 180),
                          _buildQuickRotateButton('270°', 270),
                        ],
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () => _processWithLoading('rotate', () async {
                        await Future(
                            () => imageProvider.rotateImage(_rotationAngle));
                      }),
                      icon: _processingButton == 'rotate'
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.rotate_right),
                      label: Text(_processingButton == 'rotate'
                          ? 'Memproses...'
                          : 'Apply Rotation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _processingButton == 'rotate'
                            ? AppTheme.lightColor
                            : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Scaling Card
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Scaling (Perbesaran/Pengecilan)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SliderParameter(
                        label: 'Scale Factor',
                        value: _scale,
                        min: 0.1,
                        max: 3.0,
                        divisions: 29,
                        valueLabel: '${_scale.toStringAsFixed(1)}x',
                        onChanged: (value) {
                          setState(() {
                            _scale = value;
                          });
                        },
                      ),

                      // Quick Scale Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickScaleButton('0.5x', 0.5),
                            _buildQuickScaleButton('1.0x', 1.0),
                            _buildQuickScaleButton('1.5x', 1.5),
                            _buildQuickScaleButton('2.0x', 2.0),
                          ],
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () => _processWithLoading('scale', () async {
                          await Future(() => imageProvider.scaleImage(_scale));
                        }),
                        icon: _processingButton == 'scale'
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.zoom_in),
                        label: Text(_processingButton == 'scale'
                            ? 'Memproses...'
                            : 'Apply Scaling'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _processingButton == 'scale'
                              ? AppTheme.lightColor
                              : AppTheme.primaryColor,
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

  Widget _buildQuickRotateButton(String label, double angle) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _rotationAngle = angle;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _rotationAngle == angle
            ? AppTheme.accentColor
            : AppTheme.lightColor,
        foregroundColor:
            _rotationAngle == angle ? Colors.white : AppTheme.textColor,
      ),
      child: Text(label),
    );
  }

  Widget _buildQuickScaleButton(String label, double scaleValue) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _scale = scaleValue;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _scale == scaleValue ? AppTheme.darkColor : AppTheme.lightColor,
        foregroundColor:
            _scale == scaleValue ? Colors.white : AppTheme.textColor,
      ),
      child: Text(label),
    );
  }
}
