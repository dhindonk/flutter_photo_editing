import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/models/image_model.dart';
import 'package:flutter_edit_photo_app/services/image_processor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

class ImageEditorProvider extends ChangeNotifier {
  ImageModel? _currentImage;
  List<ImageModel> _history = [];
  int _historyIndex = -1;
  bool _isProcessing = false;

  ImageModel? get currentImage => _currentImage;
  bool get hasImage => _currentImage != null;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  bool get isProcessing => _isProcessing;

  // Pilih gambar dari galeri
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      _currentImage = ImageModel.fromFile(file);
      _addToHistory(_currentImage!);
      notifyListeners();
    }
  }

  // Ambil gambar dari kamera
  Future<void> captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      _currentImage = ImageModel.fromFile(file);
      _addToHistory(_currentImage!);
      notifyListeners();
    }
  }

  // Reset gambar ke asli
  void resetImage() {
    if (_history.isNotEmpty) {
      _currentImage = _history.first;
      _historyIndex = 0;
      notifyListeners();
    }
  }

  // Hapus gambar
  void clearImage() {
    _currentImage = null;
    _history = [];
    _historyIndex = -1;
    notifyListeners();
  }

  // Undo ke state sebelumnya
  void undo() {
    if (canUndo) {
      _historyIndex--;
      _currentImage = _history[_historyIndex];
      notifyListeners();
    }
  }

  // Redo ke state selanjutnya
  void redo() {
    if (canRedo) {
      _historyIndex++;
      _currentImage = _history[_historyIndex];
      notifyListeners();
    }
  }

  // Tambahkan state ke history
  void _addToHistory(ImageModel image) {
    // Hapus forward history jika ada
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }

    _history.add(image);
    _historyIndex = _history.length - 1;
  }

  // Operasi filter gambar yang memastikan isProcessing diatur dengan benar
  Future<void> _processImageOperation(Future<void> Function() operation) async {
    if (_currentImage == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      await operation();
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Konversi ke Grayscale
  Future<void> applyGrayscale() async {
    await _processImageOperation(() async {
      final result = ImageProcessor.toGrayscale(_currentImage!);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Konversi ke Binary
  Future<void> applyBinary({int threshold = 128}) async {
    await _processImageOperation(() async {
      final result =
          ImageProcessor.toBinary(_currentImage!, threshold: threshold);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Adjust Brightness
  Future<void> adjustBrightness(int amount) async {
    await _processImageOperation(() async {
      final result =
          ImageProcessor.adjustBrightness(_currentImage!, amount: amount);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Adjust Contrast
  Future<void> adjustContrast(int amount) async {
    await _processImageOperation(() async {
      final result =
          ImageProcessor.adjustContrast(_currentImage!, amount: amount);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Histogram Equalization
  Future<void> equalizeHistogram() async {
    await _processImageOperation(() async {
      final result = ImageProcessor.equalizeHistogram(_currentImage!);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Apply Mean Filter
  Future<void> applyMeanFilter(int kernelSize) async {
    await _processImageOperation(() async {
      if (_currentImage == null) return;

      print("Applying Mean Filter with kernel size: $kernelSize");
      final result = ImageProcessor.applyMeanFilter(_currentImage!,
          kernelSize: kernelSize);

      // Verifikasi hasil
      if (result.processedImage != null && result.processedBytes != null) {
        print("Mean filter applied successfully");
        _currentImage = result;
        _addToHistory(result);
      } else {
        print("Mean filter failed to apply");
      }
    });
  }

  // Apply Median Filter
  Future<void> applyMedianFilter(int kernelSize) async {
    await _processImageOperation(() async {
      if (_currentImage == null) return;

      print("Applying Median Filter with kernel size: $kernelSize");
      final result = ImageProcessor.applyMedianFilter(_currentImage!,
          kernelSize: kernelSize);

      // Verifikasi hasil
      if (result.processedImage != null && result.processedBytes != null) {
        print("Median filter applied successfully");
        _currentImage = result;
        _addToHistory(result);
      } else {
        print("Median filter failed to apply");
      }
    });
  }

  // Apply Custom Convolution
  Future<void> applyConvolution(List<List<double>> kernel) async {
    await _processImageOperation(() async {
      if (_currentImage == null) return;

      print("Applying Custom Convolution with kernel: $kernel");
      final result = ImageProcessor.applyConvolution(_currentImage!, kernel);

      // Verifikasi hasil
      if (result.processedImage != null && result.processedBytes != null) {
        print("Convolution applied successfully");
        _currentImage = result;
        _addToHistory(result);
      } else {
        print("Convolution failed to apply");
      }
    });
  }

  // Apply Sobel Edge Detection
  Future<void> applySobel() async {
    await _processImageOperation(() async {
      final result = ImageProcessor.applySobel(_currentImage!);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Apply Prewitt Edge Detection
  Future<void> applyPrewitt() async {
    await _processImageOperation(() async {
      // Gunakan X dan Y kernel secara terpisah, lalu gabungkan hasilnya
      final xResult = ImageProcessor.applyConvolution(
          _currentImage!, ImageProcessor.prewittXKernel);
      final yResult = ImageProcessor.applyConvolution(
          _currentImage!, ImageProcessor.prewittYKernel);

      // Combine the results (simple implementation - could be improved)
      final srcImageX = xResult.processedImage;
      final srcImageY = yResult.processedImage;
      if (srcImageX != null && srcImageY != null) {
        final result = img.Image.from(srcImageX);

        for (var y = 0; y < result.height; y++) {
          for (var x = 0; x < result.width; x++) {
            final pixelX = srcImageX.getPixel(x, y);
            final pixelY = srcImageY.getPixel(x, y);

            final rX = ImageProcessor.getRed(pixelX);
            final rY = ImageProcessor.getRed(pixelY);

            final magnitude = ImageProcessor.sqrt(
                    rX.toDouble() * rX.toDouble() +
                        rY.toDouble() * rY.toDouble())
                .round()
                .clamp(0, 255);

            result.setPixel(
                x, y, img.ColorRgb8(magnitude, magnitude, magnitude));
          }
        }

        final processedBytes = Uint8List.fromList(img.encodePng(result));
        _currentImage = _currentImage!.copyWith(
          processedImage: result,
          processedBytes: processedBytes,
        );
        _addToHistory(_currentImage!);
      }
    });
  }

  // Geometric Operations

  // Translate
  Future<void> translateImage(int dx, int dy) async {
    await _processImageOperation(() async {
      final result = ImageProcessor.translate(_currentImage!, dx: dx, dy: dy);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Rotate
  Future<void> rotateImage(double angle) async {
    await _processImageOperation(() async {
      final result = ImageProcessor.rotate(_currentImage!, angle: angle);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Scale
  Future<void> scaleImage(double factor) async {
    await _processImageOperation(() async {
      final result = ImageProcessor.scale(_currentImage!, factor: factor);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Morphological Operations

  // Erosion
  Future<void> applyErosion(int iterations) async {
    await _processImageOperation(() async {
      final result =
          ImageProcessor.applyErosion(_currentImage!, iterations: iterations);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Dilation
  Future<void> applyDilation(int iterations) async {
    await _processImageOperation(() async {
      final result =
          ImageProcessor.applyDilation(_currentImage!, iterations: iterations);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Opening
  Future<void> applyOpening(int iterations) async {
    await _processImageOperation(() async {
      final result =
          ImageProcessor.applyOpening(_currentImage!, iterations: iterations);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Closing
  Future<void> applyClosing(int iterations) async {
    await _processImageOperation(() async {
      final result =
          ImageProcessor.applyClosing(_currentImage!, iterations: iterations);
      _currentImage = result;
      _addToHistory(result);
    });
  }

  // Simpan gambar
  Future<String?> saveImage(String fileName) async {
    if (_currentImage == null || _currentImage!.processedBytes == null) {
      return null;
    }

    try {
      // Minta izin akses ke gallery terlebih dahulu
      final PermissionState result =
          await PhotoManager.requestPermissionExtend();
      if (!result.isAuth) {
        print('Izin akses storage ditolak.');
        // Jika izin ditolak, gunakan cara penyimpanan biasa saja
        return _saveToNormalStorage(fileName);
      }

      // Coba simpan ke galeri menggunakan photo_manager
      try {
        final Directory appDir =
            Directory('/storage/emulated/0/Pictures/Praktikum PC');
        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }

        // Menambahkan gambar ke galeri
        final assetEntity = await PhotoManager.editor.saveImage(
          _currentImage!.processedBytes!,
          title: fileName,
          filename: '$fileName.png',
        );

        if (assetEntity != null) {
          print(
              'Gambar berhasil disimpan ke galeri: ${assetEntity.toString()}');
          return 'Galeri: $fileName';
        } else {
          print(
              'Gagal menambahkan gambar ke galeri. Mencoba metode alternatif...');
          return _saveToNormalStorage(fileName);
        }
      } catch (e) {
        print('Error saat menyimpan ke galeri: $e');
        return _saveToNormalStorage(fileName);
      }
    } catch (e) {
      print('Error saving image: $e');
      return _saveToNormalStorage(fileName);
    }
  }

  // Metode cadangan untuk menyimpan ke direktori normal
  Future<String?> _saveToNormalStorage(String fileName) async {
    try {
      final Directory appDir =
          Directory('/storage/emulated/0/Pictures/Praktikum PC');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }

      final String filePath = '${appDir.path}/$fileName.png';
      final File file = File(filePath);
      await file.writeAsBytes(_currentImage!.processedBytes!);
      print('Gambar disimpan ke: $filePath');
      return filePath;
    } catch (e) {
      print('Error menyimpan gambar ke storage: $e');
      return null;
    }
  }
}
