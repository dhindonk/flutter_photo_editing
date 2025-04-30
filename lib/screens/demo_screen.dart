import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/demo_image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/filter_button.dart';
import 'package:photo_manager/photo_manager.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> with TickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  int _brightness = 0;
  int _contrast = 0;
  double _rotationAngle = 0;
  double _scale = 1.0;
  String _activeFilter = '';
  bool _showControls = false;
  late TabController _tabController;
  final _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _checkStoragePermission();
  }

  @override
  void dispose() {
    _transformController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkStoragePermission() async {
    try {
      final permissionState = await PhotoManager.requestPermissionExtend();

      if (!permissionState.hasAccess) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Izin Penyimpanan Diperlukan'),
                content: const Text(
                  'Aplikasi ini memerlukan izin akses penyimpanan untuk memuat dan menyimpan gambar. '
                  'Tanpa izin tersebut, beberapa fitur mungkin tidak berfungsi dengan baik.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Nanti Saja'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await PhotoManager.openSetting();
                      if (mounted) {
                        _checkStoragePermission();
                      }
                    },
                    child: const Text('Buka Pengaturan'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error checking storage permission: $e');
    }
  }

  void _showSaveDialog() {
    _fileNameController.text = 'demo_prak_pc_${DateTime.now().microsecond}';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Simpan Gambar'),
          content: TextField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'Nama File',
              hintText: 'Masukkan nama file',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.primaryColor, width: 2.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final imageProvider =
                    Provider.of<DemoImageProvider>(context, listen: false);
                final result =
                    await imageProvider.saveImage(_fileNameController.text);
                Navigator.of(context).pop();

                if (!mounted) return;

                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gambar disimpan ke: $result'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(10),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Gagal menyimpan gambar'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(10),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Update image with brightness in real-time
  void _updateBrightness(double value) {
    setState(() {
      _brightness = value.toInt();
    });

    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);
    imageProvider.adjustBrightness(value);
  }

  // Reset current filter without saving to history
  void _cancelFilterAdjustment() {
    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);

    // Reset ke kondisi sebelum filter saat ini
    imageProvider.resetCurrentFilter();

    setState(() {
      // Reset hanya nilai filter yang sedang aktif
      if (_activeFilter == 'brightness') {
        _brightness = 0;
      } else if (_activeFilter == 'contrast') {
        _contrast = 0;
      } else if (_activeFilter == 'rotation') {
        _rotationAngle = 0;
      } else if (_activeFilter == 'scale') {
        _scale = 1.0;
      }
      _showControls = false;
      _activeFilter = '';
    });
  }

  // Save brightness adjustment to history
  void _saveBrightnessAdjustment() {
    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);
    imageProvider.saveBrightnessAdjustment(_brightness.toDouble());
    setState(() {
      _showControls = false;
    });
  }

  // Save contrast adjustment to history
  void _saveContrastAdjustment() {
    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);
    imageProvider.saveContrastAdjustment(_contrast.toDouble());
    setState(() {
      _showControls = false;
    });
  }

  // Update image with contrast in real-time
  void _updateContrast(double value) {
    setState(() {
      _contrast = value.toInt();
    });

    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);
    imageProvider.adjustContrast(value);
  }

  // Update rotation in real-time
  void _updateRotation(double value) {
    setState(() {
      _rotationAngle = value;
    });

    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);
    imageProvider.rotateImage(value.toInt());
  }

  // Update scale in real-time
  void _updateScale(double value) {
    setState(() {
      _scale = value;
    });

    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);
    imageProvider.scaleImage(_scale);
  }

  // Show specific filter controls
  void _showFilterControls(String filterName) {
    setState(() {
      _activeFilter = filterName;
      _showControls = true;
    });
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final imageProvider =
        Provider.of<DemoImageProvider>(context, listen: false);
    await imageProvider.pickImage();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<DemoImageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor Demo'),
        actions: <Widget>[
          if (imageProvider.canUndo)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: imageProvider.undo,
              tooltip: 'Undo',
            ),
          if (imageProvider.canRedo)
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: imageProvider.redo,
              tooltip: 'Redo',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: imageProvider.hasImage ? _showSaveDialog : null,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: imageProvider.hasImage
                ? () {
                    setState(() {
                      _brightness = 0;
                      _contrast = 0;
                      _rotationAngle = 0;
                      _scale = 1.0;
                      _activeFilter = '';
                      _showControls = false;
                    });
                    imageProvider.resetImage();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: imageProvider.hasImage
                ? () {
                    setState(() {
                      _brightness = 0;
                      _contrast = 0;
                      _rotationAngle = 0;
                      _scale = 1.0;
                      _activeFilter = '';
                      _showControls = false;
                    });
                    imageProvider.clearImage();
                  }
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top toolbar with Image picker
          if (!imageProvider.hasImage)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pilih Gambar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final provider = Provider.of<DemoImageProvider>(context,
                          listen: false);
                      await provider.captureImage();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ],
              ),
            ),

          // Canvas area
          Expanded(
            child: Container(
              color: Colors.grey[900],
              child: Stack(
                children: [
                  Center(
                    child: imageProvider.hasImage
                        ? InteractiveViewer(
                            transformationController: _transformController,
                            boundaryMargin:
                                const EdgeInsets.all(double.infinity),
                            minScale: 0.1,
                            maxScale: 5.0,
                            child: Image.memory(
                              imageProvider.currentImage!.processedBytes ??
                                  imageProvider.currentImage!.originalBytes,
                            ),
                          )
                        : const Text(
                            'Tambahkan gambar untuk mulai mengedit',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  // Overlay loading indicator yang lebih jelas
                  if (imageProvider.isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Sedang Memproses...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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

          // Filter controls panel (shown when a filter is active)
          if (_showControls) _buildControlPanel(),

          // TabBar for different filter categories
          if (imageProvider.hasImage)
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Dasar'),
                Tab(text: 'Filter'),
                Tab(text: 'Transformasi'),
                Tab(text: 'Geometri'),
                Tab(text: 'Deteksi Tepi'),
              ],
            ),

          // Bottom toolbar with filters (tabs)
          if (imageProvider.hasImage)
            SizedBox(
              height: 100,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Basic
                  ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      FilterButton(
                        label: 'Brightness',
                        icon: Icons.brightness_6,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () => _showFilterControls('brightness'),
                      ),
                      FilterButton(
                        label: 'Contrast',
                        icon: Icons.contrast,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () => _showFilterControls('contrast'),
                      ),
                      FilterButton(
                        label: 'Grayscale',
                        icon: Icons.monochrome_photos,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.applyGrayscale();
                        },
                      ),
                      FilterButton(
                        label: 'Reset',
                        icon: Icons.refresh,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.resetImage();
                        },
                      ),
                    ],
                  ),

                  // Tab 2: Filters
                  ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      FilterButton(
                        label: 'Mean Filter',
                        icon: Icons.blur_on,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.applyMeanFilter(3);
                        },
                      ),
                      FilterButton(
                        label: 'Mean 5x5',
                        icon: Icons.blur_on,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.applyMeanFilter(5);
                        },
                      ),
                      FilterButton(
                        label: 'Median',
                        icon: Icons.blur_circular,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.applyMedianFilter(3);
                        },
                      ),
                      FilterButton(
                        label: 'Median 5x5',
                        icon: Icons.blur_circular,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.applyMedianFilter(5);
                        },
                      ),
                    ],
                  ),

                  // Tab 3: Transformations
                  ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      FilterButton(
                        label: 'Rotate',
                        icon: Icons.rotate_right,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () => _showFilterControls('rotation'),
                      ),
                      FilterButton(
                        label: 'Rotate 90°',
                        icon: Icons.rotate_90_degrees_cw,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.rotateImage(90);
                        },
                      ),
                      FilterButton(
                        label: 'Rotate 180°',
                        icon: Icons.rotate_left,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.rotateImage(180);
                        },
                      ),
                      FilterButton(
                        label: 'Scale',
                        icon: Icons.zoom_in,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () => _showFilterControls('scale'),
                      ),
                    ],
                  ),

                  // Tab 4: Geometry
                  ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      FilterButton(
                        label: 'Flip H',
                        icon: Icons.flip,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.flipHorizontal();
                        },
                      ),
                      FilterButton(
                        label: 'Flip V',
                        icon: Icons.flip,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.flipVertical();
                        },
                      ),
                      FilterButton(
                        label: 'Scale 0.5x',
                        icon: Icons.zoom_out,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.scaleImage(0.5);
                        },
                      ),
                      FilterButton(
                        label: 'Scale 2x',
                        icon: Icons.zoom_in,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.scaleImage(2.0);
                        },
                      ),
                    ],
                  ),

                  // Tab 5: Edge Detection
                  ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      FilterButton(
                        label: 'Sobel',
                        icon: Icons.border_clear,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.applySobel();
                        },
                      ),
                      FilterButton(
                        label: 'Prewitt',
                        icon: Icons.line_style,
                        disabled: !imageProvider.hasImage ||
                            imageProvider.isProcessing,
                        onPressed: () {
                          imageProvider.applyPrewitt();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Build the control panel for active filter
  Widget _buildControlPanel() {
    switch (_activeFilter) {
      case 'brightness':
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black87,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Brightness',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _saveBrightnessAdjustment,
                        child: const Text('Simpan',
                            style: TextStyle(color: Colors.white)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _cancelFilterAdjustment,
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: _brightness.toDouble(),
                min: -100,
                max: 100,
                divisions: 100,
                label: _brightness.toString(),
                activeColor: AppTheme.primaryColor,
                onChanged: _updateBrightness,
              ),
              Text(
                'Value: $_brightness',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );

      case 'contrast':
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black87,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Contrast',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _saveContrastAdjustment,
                        child: const Text('Simpan',
                            style: TextStyle(color: Colors.white)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _cancelFilterAdjustment,
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: _contrast.toDouble(),
                min: -100,
                max: 100,
                divisions: 100,
                label: _contrast.toString(),
                activeColor: AppTheme.primaryColor,
                onChanged: _updateContrast,
              ),
              Text(
                'Value: $_contrast',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );

      case 'rotation':
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black87,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rotation',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _cancelFilterAdjustment,
                  ),
                ],
              ),
              Slider(
                value: _rotationAngle,
                min: 0,
                max: 360,
                divisions: 36,
                label: "${_rotationAngle.toStringAsFixed(0)}°",
                activeColor: AppTheme.primaryColor,
                onChanged: _updateRotation,
              ),
              Text(
                'Angle: ${_rotationAngle.toStringAsFixed(0)}°',
                style: const TextStyle(color: Colors.white),
              ),
              // Quick rotation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateRotation(0),
                    child: const Text('0°'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateRotation(90),
                    child: const Text('90°'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateRotation(180),
                    child: const Text('180°'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateRotation(270),
                    child: const Text('270°'),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'scale':
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black87,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scale',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _cancelFilterAdjustment,
                  ),
                ],
              ),
              Slider(
                value: _scale,
                min: 0.1,
                max: 3.0,
                divisions: 29,
                label: "${_scale.toStringAsFixed(1)}x",
                activeColor: AppTheme.primaryColor,
                onChanged: _updateScale,
              ),
              Text(
                'Scale: ${_scale.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white),
              ),
              // Quick scale buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateScale(0.5),
                    child: const Text('0.5x'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateScale(1.0),
                    child: const Text('1x'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateScale(1.5),
                    child: const Text('1.5x'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateScale(2.0),
                    child: const Text('2x'),
                  ),
                ],
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
