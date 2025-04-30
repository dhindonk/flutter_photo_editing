import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/widgets/image_preview.dart';
import 'package:flutter_edit_photo_app/widgets/filter_button.dart';
import 'package:flutter_edit_photo_app/screens/menu_screens/image_type_screen.dart';
import 'package:flutter_edit_photo_app/screens/menu_screens/pixel_operations_screen.dart';
import 'package:flutter_edit_photo_app/screens/menu_screens/convolution_screen.dart';
import 'package:flutter_edit_photo_app/screens/menu_screens/geometric_screen.dart';
import 'package:flutter_edit_photo_app/screens/menu_screens/morphology_screen.dart';
import 'package:flutter_edit_photo_app/screens/menu_screens/edge_detection_screen.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _fileName;
  final _fileNameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentBottomTab = 0;
  String? _processingButton; // Track which button is currently processing

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Periksa sekali lagi izin penyimpanan saat masuk home screen
    // Ini akan memastikan izin tersedia bahkan jika user skip dari splash screen
    // _checkStoragePermission();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSaveDialog() {
    _fileNameController.text = 'prak_pc_${DateTime.now().microsecond}';
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
                    Provider.of<ImageEditorProvider>(context, listen: false);
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

  // Quick Access Features methods with loading indicator
  void _applyQuickFeature(String featureName, Function action) async {
    setState(() {
      _processingButton = featureName;
    });

    await Future.delayed(const Duration(seconds: 1));
    try {
      await action();
    } catch (e) {
      print('Error applying quick feature: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processingButton = null;
        });
      }
    }
  }

  // Function to handle drawer item navigation with loading indicator
  void _navigateToScreen(BuildContext context, Widget screen, String title,
      ImageEditorProvider imageProvider) {
    Navigator.pop(context); // Close drawer

    if (imageProvider.hasImage) {
      // Navigasi ke screen baru dengan sedikit delay untuk menampilkan loading
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              // Bungkus screen dengan LoadingOverlay untuk menampilkan loading selama proses
              return LoadingAwareScreen(
                child: screen,
                imageProvider: imageProvider,
              );
            }),
          );
        }
      });
    } else {
      // Tampilkan pesan error jika belum ada gambar yang dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silahkan pilih gambar terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  // Function untuk memeriksa izin storage
  Future<void> _checkStoragePermission() async {
    try {
      // Periksa status izin penyimpanan
      final permissionState = await PhotoManager.requestPermissionExtend();

      if (!permissionState.hasAccess) {
        // Jika belum diizinkan, tampilkan dialog
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
                      // Buka setting aplikasi
                      await PhotoManager.openSetting();
                      // Periksa kembali setelah kembali dari settings
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

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageEditorProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Pengolahan Citra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (imageProvider.hasImage)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: imageProvider.resetImage,
              tooltip: 'Reset ke asli',
            ),
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
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Praktikum Pengolahan Citra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belajar & Aplikasikan Pengolahan Citra Digital',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.image,
              title: 'Jenis Citra',
              screen: const ImageTypeScreen(),
              imageProvider: imageProvider,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.tune,
              title: 'Operasi Pixel & Histogram',
              screen: const PixelOperationsScreen(),
              imageProvider: imageProvider,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.filter,
              title: 'Konvolusi & Ketetanggaan',
              screen: const ConvolutionScreen(),
              imageProvider: imageProvider,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.transform,
              title: 'Operasi Geometri',
              screen: const GeometricScreen(),
              imageProvider: imageProvider,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.blur_on,
              title: 'Morfologi Citra',
              screen: const MorphologyScreen(),
              imageProvider: imageProvider,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.line_style,
              title: 'Deteksi Tepi',
              screen: const EdgeDetectionScreen(),
              imageProvider: imageProvider,
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppTheme.primaryColor),
              ),
              title: const Text('Demo Mode'),
              subtitle: const Text('Semua fitur dapat diuji coba'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/demo');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Tentang Aplikasi'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pengolahan Citra App'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Versi: v0.1.0'),
                        SizedBox(height: 8),
                        Text('© 2025 Maroon Labkom'),
                        SizedBox(height: 16),
                        Text(
                          'Aplikasi ini dibuat untuk membantu praktikum pengolahan citra agar lebih mudah dipahami secara langsung.',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('TUTUP'),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.grey[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _animation,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main content area
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image Preview Card
                          Stack(
                            children: [
                              // Image Preview
                              if (imageProvider.hasImage)
                                ImagePreview(
                                  originalImage:
                                      imageProvider.currentImage!.originalBytes,
                                  processedImage: imageProvider
                                      .currentImage!.processedBytes,
                                  isProcessing:
                                      false, // Kita tangani loading di level atas
                                )
                              else
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_search,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Belum Ada Gambar Dipilih',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Gunakan tombol di bawah untuk memuat gambar',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Loading Overlay
                              if (imageProvider.isProcessing)
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
                                          'Memproses...',
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Bottom Action Bar - Fixed position
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab indicators
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: imageProvider.hasImage
                  ? [
                      _buildTabButton(
                        title: 'Action',
                        icon: Icons.edit,
                        isSelected: _currentBottomTab == 0,
                        onTap: () => setState(() => _currentBottomTab = 0),
                      ),
                      _buildTabButton(
                        title: 'Quick Access',
                        icon: Icons.bolt,
                        isSelected: _currentBottomTab == 1,
                        onTap: () => setState(() => _currentBottomTab = 1),
                      ),
                    ]
                  : [],
            ),
          ),

          // Content based on selected tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              color: Colors.white,
              child: IndexedStack(
                index: _currentBottomTab,
                children: [
                  // Tab 1: Main Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          label: 'Galeri',
                          icon: Icons.photo_library,
                          color: Colors.blue,
                          onPressed: () async {
                            await imageProvider.pickImage();
                          },
                        ),
                        _buildActionButton(
                          label: 'Kamera',
                          icon: Icons.camera_alt,
                          color: Colors.green,
                          onPressed: () async {
                            await imageProvider.captureImage();
                          },
                        ),
                        _buildActionButton(
                          label: 'Simpan',
                          icon: Icons.save,
                          color: Colors.purple,
                          onPressed:
                              imageProvider.hasImage ? _showSaveDialog : null,
                          disabled: !imageProvider.hasImage,
                        ),
                        _buildActionButton(
                          label: 'Hapus',
                          icon: Icons.delete,
                          color: Colors.red,
                          onPressed: imageProvider.hasImage
                              ? () {
                                  setState(() {
                                    imageProvider.clearImage();
                                  });
                                }
                              : null,
                          disabled: !imageProvider.hasImage,
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Quick Access Features (only visible if image is loaded)
                  if (imageProvider.hasImage)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12.0),
                        child: Row(
                          children: [
                            _buildQuickAccessButton(
                              label: 'Grayscale',
                              icon: Icons.image,
                              isProcessing: _processingButton == 'Grayscale',
                              onPressed: () {
                                _applyQuickFeature('Grayscale', () async {
                                  imageProvider.applyGrayscale();
                                });
                              },
                            ),
                            _buildQuickAccessButton(
                              label: 'Brightness',
                              icon: Icons.brightness_6,
                              isProcessing: _processingButton == 'Brightness',
                              onPressed: () {
                                _applyQuickFeature('Brightness', () async {
                                  imageProvider.adjustBrightness(30);
                                });
                              },
                            ),
                            _buildQuickAccessButton(
                              label: 'Blur',
                              icon: Icons.blur_on,
                              isProcessing: _processingButton == 'Blur',
                              onPressed: () {
                                _applyQuickFeature('Blur', () async {
                                  imageProvider.applyMeanFilter(5);
                                });
                              },
                            ),
                            _buildQuickAccessButton(
                              label: 'Edge',
                              icon: Icons.line_style,
                              isProcessing: _processingButton == 'Edge',
                              onPressed: () {
                                _applyQuickFeature('Edge', () async {
                                  imageProvider.applySobel();
                                });
                              },
                            ),
                            _buildQuickAccessButton(
                              label: 'Rotate',
                              icon: Icons.rotate_right,
                              isProcessing: _processingButton == 'Rotate',
                              onPressed: () {
                                _applyQuickFeature('Rotate', () async {
                                  imageProvider.rotateImage(90);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget screen,
    required ImageEditorProvider imageProvider,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      onTap: () => _navigateToScreen(context, screen, title, imageProvider),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool disabled = false,
  }) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: disabled ? Colors.grey[300] : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: disabled ? Colors.grey : color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: disabled ? Colors.grey : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isProcessing = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : onPressed,
        icon: isProcessing
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isProcessing ? AppTheme.accentColor : AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// Widget pembungkus untuk menampilkan loading overlay pada screen yang dibuka
class LoadingAwareScreen extends StatelessWidget {
  final Widget child;
  final ImageEditorProvider imageProvider;

  const LoadingAwareScreen({
    super.key,
    required this.child,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tampilkan screen asli
        child,

        // Tampilkan loading overlay jika sedang dalam proses
        Consumer<ImageEditorProvider>(
          builder: (context, provider, _) {
            if (provider.isProcessing) {
              return Container(
                color: Colors.black.withOpacity(0.5),
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
                        'Sedang memproses...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
