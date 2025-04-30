import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/models/image_model.dart';
import 'package:flutter_edit_photo_app/services/image_processor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

class DemoImageProvider extends ChangeNotifier {
  // State management
  ImageModel? _currentImage;
  img.Image? _processedImgCache;
  List<ImageModel> _history = [];
  int _historyIndex = -1;
  bool _isProcessing = false;
  Timer? _debounceTimer;

  // Gambar asli di cache sebelum aplikasi filter saat ini
  img.Image? _preFilterImage;

  // Parameter operasi saat ini
  double _brightness = 0;
  double _contrast = 0;
  double _saturation = 0;
  double _hue = 0;
  double _blur = 0;
  double _sharpen = 0;
  double _noise = 0;
  double _vignette = 0;
  double _temperature = 0;
  double _tint = 0;
  double _exposure = 0;
  double _gamma = 1.0;

  // Getters
  ImageModel? get currentImage => _currentImage;
  bool get hasImage => _currentImage != null;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  bool get isProcessing => _isProcessing;

  // Getter parameter
  double get brightness => _brightness;
  double get contrast => _contrast;
  double get saturation => _saturation;
  double get hue => _hue;
  double get blur => _blur;
  double get sharpen => _sharpen;
  double get noise => _noise;
  double get vignette => _vignette;
  double get temperature => _temperature;
  double get tint => _tint;
  double get exposure => _exposure;
  double get gamma => _gamma;

  // Debounce untuk pratinjau real-time
  void _debounce(VoidCallback callback,
      {Duration duration = const Duration(milliseconds: 200)}) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(duration, callback);
  }

  // Dapatkan data gambar terbaru
  img.Image? _getLatestImageData() {
    if (_processedImgCache != null) {
      return _processedImgCache;
    }
    if (_currentImage != null) {
      final processedImage = _currentImage!.processedImage;
      if (processedImage != null) {
        _processedImgCache = processedImage;
        return processedImage;
      }
      final originalImage = _currentImage!.image;
      if (originalImage != null) {
        _processedImgCache = originalImage;
        return originalImage;
      }
    }
    return null;
  }

  // Buat ImageModel dari gambar yang telah diproses
  ImageModel _createImageModel(img.Image processedImage) {
    final bytes = Uint8List.fromList(img.encodePng(processedImage));

    if (_currentImage == null) {
      return ImageModel(
        originalBytes: bytes,
        processedBytes: bytes,
        processedImage: processedImage,
        image: processedImage,
      );
    }

    return _currentImage!.copyWith(
      processedBytes: bytes,
      processedImage: processedImage,
    );
  }

  // Tambahkan ke histori
  void _addToHistory(ImageModel image, img.Image processedImg) {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }

    _history.add(image);
    _historyIndex = _history.length - 1;
    _processedImgCache = processedImg;
    _currentImage = image;

    debugPrint(
        "Histori diperbarui - Indeks saat ini: $_historyIndex, Total: ${_history.length}");
  }

  // Simpan gambar sebelum menerapkan filter
  void _savePreFilterState() {
    final srcImg = _getLatestImageData();
    if (srcImg != null && _preFilterImage == null) {
      _preFilterImage = img.Image.from(srcImg);
    }
  }

  // Kembalikan ke keadaan sebelum filter saat ini
  void resetCurrentFilter() {
    if (_preFilterImage != null) {
      final resultModel = _createImageModel(_preFilterImage!);
      _currentImage = resultModel;
      _processedImgCache = _preFilterImage;
      _preFilterImage = null;
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Terapkan semua penyesuaian saat ini
  void _applyAllAdjustments() {
    final srcImg = _preFilterImage ?? _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    _debounce(() {
      try {
        var resultImg = img.Image.from(srcImg);

        // Terapkan penyesuaian dari yang paling tidak destruktif ke yang paling destruktif
        if (_brightness != 0) {
          resultImg = _manualBrightnessAdjust(resultImg, _brightness);
        }
        if (_contrast != 0) {
          resultImg = _manualContrastAdjust(resultImg, _contrast);
        }
        if (_saturation != 0) {
          resultImg =
              img.adjustColor(resultImg, saturation: 1 + (_saturation / 100));
        }
        if (_hue != 0) {
          resultImg = img.adjustColor(resultImg, hue: _hue);
        }
        if (_blur > 0) {
          resultImg = img.gaussianBlur(resultImg, radius: _blur.toInt());
        }
        if (_sharpen > 0) {
          resultImg = _sharpenImage(resultImg, amount: _sharpen / 100);
        }
        if (_noise > 0) {
          resultImg = _addNoise(resultImg, amount: _noise / 100);
        }
        if (_vignette > 0) {
          resultImg = _applyVignette(resultImg, amount: _vignette / 100);
        }
        if (_temperature != 0) {
          resultImg = _adjustTemperature(resultImg, amount: _temperature / 100);
        }
        if (_tint != 0) {
          resultImg = _adjustTint(resultImg, amount: _tint / 100);
        }
        if (_exposure != 0) {
          resultImg = img.adjustColor(resultImg, exposure: _exposure / 100);
        }
        if (_gamma != 1.0) {
          resultImg = img.adjustColor(resultImg, gamma: _gamma);
        }

        // Perbarui gambar saat ini tanpa menyimpan ke histori
        final resultModel = _createImageModel(resultImg);
        _currentImage = resultModel;
        _processedImgCache = resultImg;
      } catch (e) {
        debugPrint("Error menerapkan penyesuaian: $e");
      } finally {
        _isProcessing = false;
        notifyListeners();
      }
    });
  }

  // Implementasi brightness manual yang lebih andal
  img.Image _manualBrightnessAdjust(img.Image src, double amount) {
    final resultImg = img.Image.from(src);

    // Faktor skala yang lebih tepat untuk mencegah flat black/white
    double scaleFactor = 1.5;

    // Kurva respons non-linear untuk nilai ekstrim
    if (amount < -80) {
      // Sangat hati-hati dengan penggelapan ekstrim
      double normalizedAmount = -80 + (amount + 80) * 0.2;
      amount = normalizedAmount;
    } else if (amount > 80) {
      // Sangat hati-hati dengan penerangan ekstrim
      double normalizedAmount = 80 + (amount - 80) * 0.2;
      amount = normalizedAmount;
    }

    // Konversi ke nilai adjustment
    final adjustmentValue = (amount * scaleFactor).round();

    // Terapkan ke setiap pixel
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);

        // Kenaikan/penurunan nilai dengan batas minimum 1 (bukan 0) untuk mencegah hitam total
        int r = (pixel.r + adjustmentValue).clamp(1, 254).toInt();
        int g = (pixel.g + adjustmentValue).clamp(1, 254).toInt();
        int b = (pixel.b + adjustmentValue).clamp(1, 254).toInt();

        resultImg.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return resultImg;
  }

  // Implementasi contrast manual yang lebih andal
  img.Image _manualContrastAdjust(img.Image src, double amount) {
    final resultImg = img.Image.from(src);

    // Batasi nilai amount ke range yang aman
    double safeAmount = amount;

    // Gunakan pendekatan yang lebih konservatif
    // Konversi -100..100 ke range faktor kontras 0.5..1.5
    // Ini menjaga gambar tetap terlihat di semua nilai
    double contrastFactor = 1.0; // Default = tidak ada perubahan

    if (safeAmount > 0) {
      // Positif: 0..100 -> 1.0..1.5
      contrastFactor = 1.0 + (safeAmount / 200.0);
    } else {
      // Negatif: -100..0 -> 0.5..1.0
      contrastFactor = 1.0 + (safeAmount / 200.0);
    }

    // Nilai tengah untuk penyesuaian kontras
    const midPoint = 128;

    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);

        // Hitung nilai baru berdasarkan faktor kontras
        int r = ((pixel.r - midPoint) * contrastFactor + midPoint)
            .round()
            .clamp(1, 254);
        int g = ((pixel.g - midPoint) * contrastFactor + midPoint)
            .round()
            .clamp(1, 254);
        int b = ((pixel.b - midPoint) * contrastFactor + midPoint)
            .round()
            .clamp(1, 254);

        resultImg.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return resultImg;
  }

  // Implementasi manual efek sharpen
  img.Image _sharpenImage(img.Image src, {required double amount}) {
    final result = img.Image.from(src);
    final kernel = [
      [0, -1, 0],
      [-1, 5, -1],
      [0, -1, 0]
    ];

    for (var y = 1; y < src.height - 1; y++) {
      for (var x = 1; x < src.width - 1; x++) {
        var r = 0, g = 0, b = 0;

        for (var ky = -1; ky <= 1; ky++) {
          for (var kx = -1; kx <= 1; kx++) {
            final pixel = src.getPixel(x + kx, y + ky);
            final weight = kernel[ky + 1][kx + 1];
            r += (pixel.r * weight).round().clamp(0, 255);
            g += (pixel.g * weight).round().clamp(0, 255);
            b += (pixel.b * weight).round().clamp(0, 255);
          }
        }

        // Campurkan dengan asli berdasarkan jumlah
        final original = src.getPixel(x, y);
        r = (r * amount + original.r * (1 - amount)).round().clamp(0, 255);
        g = (g * amount + original.g * (1 - amount)).round().clamp(0, 255);
        b = (b * amount + original.b * (1 - amount)).round().clamp(0, 255);

        result.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return result;
  }

  // Implementasi manual efek noise
  img.Image _addNoise(img.Image src, {required double amount}) {
    final result = img.Image.from(src);
    final random = Random();

    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final noise = (random.nextDouble() * 2 - 1) * 255 * amount;

        final r = (pixel.r + noise).round().clamp(0, 255);
        final g = (pixel.g + noise).round().clamp(0, 255);
        final b = (pixel.b + noise).round().clamp(0, 255);

        result.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return result;
  }

  // Implementasi manual efek vignette
  img.Image _applyVignette(img.Image src, {required double amount}) {
    final result = img.Image.from(src);
    final centerX = src.width / 2;
    final centerY = src.height / 2;
    final maxDist = sqrt(centerX * centerX + centerY * centerY);

    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final dist = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
        final vignette = 1 - (dist / maxDist) * amount;

        final r = (pixel.r * vignette).round().clamp(0, 255).toInt();
        final g = (pixel.g * vignette).round().clamp(0, 255).toInt();
        final b = (pixel.b * vignette).round().clamp(0, 255).toInt();

        result.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return result;
  }

  // Implementasi manual penyesuaian temperatur
  img.Image _adjustTemperature(img.Image src, {required double amount}) {
    final result = img.Image.from(src);
    final factor = 1 + amount;

    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final r = (pixel.r * factor).round().clamp(1, 254).toInt();
        final g = pixel.g.toInt();
        final b = (pixel.b / factor).round().clamp(1, 254).toInt();

        result.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return result;
  }

  // Implementasi manual penyesuaian tint
  img.Image _adjustTint(img.Image src, {required double amount}) {
    final result = img.Image.from(src);
    final factor = 1 + amount;

    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = (pixel.g * factor).round().clamp(1, 254).toInt();
        final b = (pixel.b * factor).round().clamp(1, 254).toInt();

        result.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return result;
  }

  // Simpan penyesuaian saat ini ke histori
  void saveAdjustments() {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      var resultImg = img.Image.from(srcImg);

      // Terapkan semua penyesuaian
      if (_brightness != 0) {
        resultImg = _manualBrightnessAdjust(resultImg, _brightness);
      }
      if (_contrast != 0) {
        resultImg = _manualContrastAdjust(resultImg, _contrast);
      }
      if (_saturation != 0) {
        resultImg =
            img.adjustColor(resultImg, saturation: 1 + (_saturation / 100));
      }
      if (_hue != 0) {
        resultImg = img.adjustColor(resultImg, hue: _hue);
      }
      if (_blur > 0) {
        resultImg = img.gaussianBlur(resultImg, radius: _blur.toInt());
      }
      if (_sharpen > 0) {
        resultImg = _sharpenImage(resultImg, amount: _sharpen / 100);
      }
      if (_noise > 0) {
        resultImg = _addNoise(resultImg, amount: _noise / 100);
      }
      if (_vignette > 0) {
        resultImg = _applyVignette(resultImg, amount: _vignette / 100);
      }
      if (_temperature != 0) {
        resultImg = _adjustTemperature(resultImg, amount: _temperature / 100);
      }
      if (_tint != 0) {
        resultImg = _adjustTint(resultImg, amount: _tint / 100);
      }
      if (_exposure != 0) {
        resultImg = img.adjustColor(resultImg, exposure: _exposure / 100);
      }
      if (_gamma != 1.0) {
        resultImg = img.adjustColor(resultImg, gamma: _gamma);
      }

      // Simpan ke histori
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);

      // Reset preFilterImage setelah penyimpanan
      _preFilterImage = null;
    } catch (e) {
      debugPrint("Error menyimpan penyesuaian: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Setter parameter dengan pratinjau real-time
  void setBrightness(double value) {
    _savePreFilterState();
    _brightness = value;
    _applyAllAdjustments();
  }

  void setContrast(double value) {
    _savePreFilterState();
    _contrast = value;
    _applyAllAdjustments();
  }

  void setSaturation(double value) {
    _savePreFilterState();
    _saturation = value;
    _applyAllAdjustments();
  }

  void setHue(double value) {
    _savePreFilterState();
    _hue = value;
    _applyAllAdjustments();
  }

  void setBlur(double value) {
    _savePreFilterState();
    _blur = value;
    _applyAllAdjustments();
  }

  void setSharpen(double value) {
    _savePreFilterState();
    _sharpen = value;
    _applyAllAdjustments();
  }

  void setNoise(double value) {
    _savePreFilterState();
    _noise = value;
    _applyAllAdjustments();
  }

  void setVignette(double value) {
    _savePreFilterState();
    _vignette = value;
    _applyAllAdjustments();
  }

  void setTemperature(double value) {
    _savePreFilterState();
    _temperature = value;
    _applyAllAdjustments();
  }

  void setTint(double value) {
    _savePreFilterState();
    _tint = value;
    _applyAllAdjustments();
  }

  void setExposure(double value) {
    _savePreFilterState();
    _exposure = value;
    _applyAllAdjustments();
  }

  void setGamma(double value) {
    _savePreFilterState();
    _gamma = value;
    _applyAllAdjustments();
  }

  // Reset semua penyesuaian
  void resetAdjustments() {
    _brightness = 0;
    _contrast = 0;
    _saturation = 0;
    _hue = 0;
    _blur = 0;
    _sharpen = 0;
    _noise = 0;
    _vignette = 0;
    _temperature = 0;
    _tint = 0;
    _exposure = 0;
    _gamma = 1.0;
    _preFilterImage = null;
    _applyAllAdjustments();
  }

  // Image loading and saving
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final newImage = ImageModel.fromFile(file);

      _currentImage = newImage;
      _processedImgCache = newImage.image;
      _history = [newImage];
      _historyIndex = 0;
      resetAdjustments();

      notifyListeners();
      debugPrint("New image picked from gallery");
    }
  }

  Future<void> captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final newImage = ImageModel.fromFile(file);

      _currentImage = newImage;
      _processedImgCache = newImage.image;
      _history = [newImage];
      _historyIndex = 0;
      resetAdjustments();

      notifyListeners();
      debugPrint("New image captured from camera");
    }
  }

  void resetImage() {
    if (_history.isNotEmpty) {
      _currentImage = _history.first;
      _processedImgCache = _currentImage?.image;
      _historyIndex = 0;
      resetAdjustments();
      notifyListeners();
      debugPrint("Image reset to first version");
    }
  }

  void clearImage() {
    _currentImage = null;
    _processedImgCache = null;
    _history = [];
    _historyIndex = -1;
    resetAdjustments();
    notifyListeners();
    debugPrint("Image cleared");
  }

  void undo() {
    if (canUndo) {
      _historyIndex--;
      _currentImage = _history[_historyIndex];
      _processedImgCache =
          _currentImage?.processedImage ?? _currentImage?.image;
      notifyListeners();
      debugPrint("Undo to index: $_historyIndex");
    }
  }

  void redo() {
    if (canRedo) {
      _historyIndex++;
      _currentImage = _history[_historyIndex];
      _processedImgCache =
          _currentImage?.processedImage ?? _currentImage?.image;
      notifyListeners();
      debugPrint("Redo to index: $_historyIndex");
    }
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
        debugPrint('Izin akses storage ditolak.');
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
          debugPrint(
              'Gambar berhasil disimpan ke galeri: ${assetEntity.toString()}');
          return 'Galeri: $fileName';
        } else {
          debugPrint(
              'Gagal menambahkan gambar ke galeri. Mencoba metode alternatif...');
          return _saveToNormalStorage(fileName);
        }
      } catch (e) {
        debugPrint('Error saat menyimpan ke galeri: $e');
        return _saveToNormalStorage(fileName);
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
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
      debugPrint('Gambar disimpan ke: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error menyimpan gambar ke storage: $e');
      return null;
    }
  }

  // Additional methods needed by demo_screen.dart
  void adjustBrightness(double amount) {
    setBrightness(amount);
  }

  void saveBrightnessAdjustment(double amount) {
    setBrightness(amount);
    saveAdjustments();
  }

  void adjustContrast(double amount) {
    setContrast(amount);
  }

  void saveContrastAdjustment(double amount) {
    setContrast(amount);
    saveAdjustments();
  }

  void rotateImage(int degrees) {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final resultImg = img.copyRotate(srcImg, angle: degrees);
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error rotating image: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void scaleImage(double factor) {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final newWidth = (srcImg.width * factor).round();
      final newHeight = (srcImg.height * factor).round();
      final resultImg =
          img.copyResize(srcImg, width: newWidth, height: newHeight);
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error scaling image: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void applyGrayscale() {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final resultImg = img.grayscale(srcImg);
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error applying grayscale: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void applyMeanFilter(int kernelSize) {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final resultImg = img.gaussianBlur(srcImg, radius: kernelSize ~/ 2);
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error applying mean filter: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void applyMedianFilter(int kernelSize) {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final resultImg = img.gaussianBlur(srcImg, radius: kernelSize ~/ 2);
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error applying median filter: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void flipHorizontal() {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final resultImg = img.flipHorizontal(srcImg);
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error flipping image horizontally: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void flipVertical() {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final resultImg = img.flipVertical(srcImg);
      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error flipping image vertically: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void applySobel() {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      var grayImg = img.grayscale(srcImg);

      final sobelX = [
        [-1, 0, 1],
        [-2, 0, 2],
        [-1, 0, 1]
      ];

      final sobelY = [
        [1, 2, 1],
        [0, 0, 0],
        [-1, -2, -1]
      ];

      final resultImg = img.Image.from(grayImg);

      for (var y = 1; y < grayImg.height - 1; y++) {
        for (var x = 1; x < grayImg.width - 1; x++) {
          var gradX = 0;
          var gradY = 0;

          for (var ky = -1; ky <= 1; ky++) {
            for (var kx = -1; kx <= 1; kx++) {
              final pixel = grayImg.getPixel(x + kx, y + ky);
              final gray = pixel.r;

              gradX += (gray * sobelX[ky + 1][kx + 1]).toInt();
              gradY += (gray * sobelY[ky + 1][kx + 1]).toInt();
            }
          }

          final magnitude =
              sqrt(gradX * gradX + gradY * gradY).round().clamp(0, 255);

          resultImg.setPixel(
              x, y, img.ColorRgb8(magnitude, magnitude, magnitude));
        }
      }

      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error applying Sobel filter: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void applyPrewitt() {
    final srcImg = _getLatestImageData();
    if (srcImg == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      var grayImg = img.grayscale(srcImg);

      final prewittX = [
        [-1, 0, 1],
        [-1, 0, 1],
        [-1, 0, 1]
      ];

      final prewittY = [
        [1, 1, 1],
        [0, 0, 0],
        [-1, -1, -1]
      ];

      final resultImg = img.Image.from(grayImg);

      for (var y = 1; y < grayImg.height - 1; y++) {
        for (var x = 1; x < grayImg.width - 1; x++) {
          var gradX = 0;
          var gradY = 0;

          for (var ky = -1; ky <= 1; ky++) {
            for (var kx = -1; kx <= 1; kx++) {
              final pixel = grayImg.getPixel(x + kx, y + ky);
              final gray = pixel.r;

              gradX += (gray * prewittX[ky + 1][kx + 1]).toInt();
              gradY += (gray * prewittY[ky + 1][kx + 1]).toInt();
            }
          }

          final magnitude =
              sqrt(gradX * gradX + gradY * gradY).round().clamp(0, 255);

          resultImg.setPixel(
              x, y, img.ColorRgb8(magnitude, magnitude, magnitude));
        }
      }

      final resultModel = _createImageModel(resultImg);
      _addToHistory(resultModel, resultImg);
    } catch (e) {
      debugPrint("Error applying Prewitt filter: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
