import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter_edit_photo_app/models/image_model.dart';

class ImageProcessor {
  // Fungsi Helper untuk mendapatkan nilai RGB dari tipe Pixel
  static int getRed(img.Pixel pixel) => pixel.r.toInt();
  static int getGreen(img.Pixel pixel) => pixel.g.toInt();
  static int getBlue(img.Pixel pixel) => pixel.b.toInt();
  static int getLuminance(img.Pixel pixel) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    return ((0.299 * r) + (0.587 * g) + (0.114 * b)).round();
  }

  // ---------------- Jenis Citra ----------------
  // Konversi RGB ke Grayscale
  static ImageModel toGrayscale(ImageModel source) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    final grayscale = img.grayscale(srcImage);
    final processedBytes = Uint8List.fromList(img.encodePng(grayscale));

    return source.copyWith(
      processedImage: grayscale,
      processedBytes: processedBytes,
    );
  }

  // Konversi RGB ke Biner dengan threshold manual
  static ImageModel toBinary(ImageModel source, {int threshold = 128}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Konversi ke grayscale terlebih dahulu
    final grayscale = img.grayscale(srcImage);

    // Implementasi manual untuk binarize
    final binary = img.Image.from(grayscale);
    for (var y = 0; y < binary.height; y++) {
      for (var x = 0; x < binary.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final gray = getLuminance(pixel);
        binary.setPixel(
            x,
            y,
            gray > threshold
                ? img.ColorRgb8(255, 255, 255)
                : img.ColorRgb8(0, 0, 0));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(binary));

    return source.copyWith(
      processedImage: binary,
      processedBytes: processedBytes,
    );
  }

  // ---------------- Operasi Pixel dan Histogram ----------------
  // Brightness Adjustment
  static ImageModel adjustBrightness(ImageModel source, {int amount = 0}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi manual untuk brightness
    final brightened = img.Image.from(srcImage);
    for (var y = 0; y < brightened.height; y++) {
      for (var x = 0; x < brightened.width; x++) {
        final pixel = srcImage.getPixel(x, y);
        final r = getRed(pixel) + amount;
        final g = getGreen(pixel) + amount;
        final b = getBlue(pixel) + amount;

        brightened.setPixel(x, y,
            img.ColorRgb8(r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255)));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(brightened));

    return source.copyWith(
      processedImage: brightened,
      processedBytes: processedBytes,
    );
  }

  // Contrast Adjustment
  static ImageModel adjustContrast(ImageModel source, {int amount = 0}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi manual untuk contrast
    final factor = (259 * (amount + 255)) / (255 * (259 - amount));
    final contrasted = img.Image.from(srcImage);

    for (var y = 0; y < contrasted.height; y++) {
      for (var x = 0; x < contrasted.width; x++) {
        final pixel = srcImage.getPixel(x, y);
        final r = factor * (getRed(pixel) - 128) + 128;
        final g = factor * (getGreen(pixel) - 128) + 128;
        final b = factor * (getBlue(pixel) - 128) + 128;

        contrasted.setPixel(
            x,
            y,
            img.ColorRgb8(r.clamp(0, 255).toInt(), g.clamp(0, 255).toInt(),
                b.clamp(0, 255).toInt()));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(contrasted));

    return source.copyWith(
      processedImage: contrasted,
      processedBytes: processedBytes,
    );
  }

  // Histogram Equalization
  static ImageModel equalizeHistogram(ImageModel source) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi histogram equalization manual
    final grayscale = img.grayscale(srcImage);
    final equalized = img.Image.from(grayscale);

    // Hitung histogram
    final histogram = List<int>.filled(256, 0);
    for (var y = 0; y < grayscale.height; y++) {
      for (var x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final gray = getRed(pixel); // Grayscale jadi R=G=B
        histogram[gray]++;
      }
    }

    // Hitung CDF (Cumulative Distribution Function)
    final cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (var i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    // Normalize CDF
    final totalPixels = grayscale.width * grayscale.height;
    final cdfMin = cdf.firstWhere((count) => count > 0, orElse: () => 0);

    // Equalizer function
    final equalizer = List<int>.filled(256, 0);
    for (var i = 0; i < 256; i++) {
      equalizer[i] = ((cdf[i] - cdfMin) * 255 / (totalPixels - cdfMin))
          .round()
          .clamp(0, 255);
    }

    // Apply equalization
    for (var y = 0; y < equalized.height; y++) {
      for (var x = 0; x < equalized.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final gray = getRed(pixel);
        final newValue = equalizer[gray];
        equalized.setPixel(x, y, img.ColorRgb8(newValue, newValue, newValue));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(equalized));

    return source.copyWith(
      processedImage: equalized,
      processedBytes: processedBytes,
    );
  }

  // ---------------- Operasi Ketetanggaan & Konvolusi ----------------
  // Filter Rerata (Mean)
  static ImageModel applyMeanFilter(ImageModel source, {int kernelSize = 3}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi langsung dengan library image
    final filtered = img.Image.from(srcImage);
    final halfSize = kernelSize ~/ 2;

    // Implementasi manual untuk mean filter
    for (var y = halfSize; y < srcImage.height - halfSize; y++) {
      for (var x = halfSize; x < srcImage.width - halfSize; x++) {
        int sumR = 0, sumG = 0, sumB = 0;
        int count = 0;

        // Kumpulkan nilai-nilai pixel tetangga
        for (var ky = -halfSize; ky <= halfSize; ky++) {
          for (var kx = -halfSize; kx <= halfSize; kx++) {
            final pixel = srcImage.getPixel(x + kx, y + ky);
            sumR += getRed(pixel);
            sumG += getGreen(pixel);
            sumB += getBlue(pixel);
            count++;
          }
        }

        // Hitung rata-rata
        final avgR = (sumR / count).round();
        final avgG = (sumG / count).round();
        final avgB = (sumB / count).round();

        // Set pixel dengan nilai rata-rata
        filtered.setPixel(x, y, img.ColorRgb8(avgR, avgG, avgB));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(filtered));

    return source.copyWith(
      processedImage: filtered,
      processedBytes: processedBytes,
    );
  }

  // Filter Median
  static ImageModel applyMedianFilter(ImageModel source, {int kernelSize = 3}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi manual filter median
    final filtered = img.Image.from(srcImage);
    final halfSize = kernelSize ~/ 2;

    for (var y = halfSize; y < srcImage.height - halfSize; y++) {
      for (var x = halfSize; x < srcImage.width - halfSize; x++) {
        final rValues = <int>[];
        final gValues = <int>[];
        final bValues = <int>[];

        // Kumpulkan nilai-nilai pixel tetangga
        for (var ky = -halfSize; ky <= halfSize; ky++) {
          for (var kx = -halfSize; kx <= halfSize; kx++) {
            final pixel = srcImage.getPixel(x + kx, y + ky);
            rValues.add(getRed(pixel));
            gValues.add(getGreen(pixel));
            bValues.add(getBlue(pixel));
          }
        }

        // Urutkan nilai
        rValues.sort();
        gValues.sort();
        bValues.sort();

        // Ambil nilai tengah (median)
        final medianPos = rValues.length ~/ 2;
        filtered.setPixel(
            x,
            y,
            img.ColorRgb8(
                rValues[medianPos], gValues[medianPos], bValues[medianPos]));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(filtered));

    return source.copyWith(
      processedImage: filtered,
      processedBytes: processedBytes,
    );
  }

  // Konvolusi dengan kernel kustom
  static ImageModel applyConvolution(
      ImageModel source, List<List<double>> kernel) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi manual konvolusi
    final kHeight = kernel.length;
    final kWidth = kernel[0].length;
    final halfKHeight = kHeight ~/ 2;
    final halfKWidth = kWidth ~/ 2;

    final filtered = img.Image.from(srcImage);

    // Untuk debug: print kernel
    print('Applying convolution with kernel:');
    for (var row in kernel) {
      print(row);
    }

    for (var y = halfKHeight; y < srcImage.height - halfKHeight; y++) {
      for (var x = halfKWidth; x < srcImage.width - halfKWidth; x++) {
        double sumR = 0, sumG = 0, sumB = 0;

        for (var ky = 0; ky < kHeight; ky++) {
          for (var kx = 0; kx < kWidth; kx++) {
            final srcX = x + kx - halfKWidth;
            final srcY = y + ky - halfKHeight;
            final pixel = srcImage.getPixel(srcX, srcY);

            sumR += getRed(pixel) * kernel[ky][kx];
            sumG += getGreen(pixel) * kernel[ky][kx];
            sumB += getBlue(pixel) * kernel[ky][kx];
          }
        }

        // Pastikan nilai dalam rentang yang valid
        int r = sumR.round().clamp(0, 255);
        int g = sumG.round().clamp(0, 255);
        int b = sumB.round().clamp(0, 255);

        filtered.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(filtered));

    // Debug info
    print('Convolution applied. Image processed.');

    return source.copyWith(
      processedImage: filtered,
      processedBytes: processedBytes,
    );
  }

  // ---------------- Operasi Geometri ----------------
  // Translasi (geser gambar)
  static ImageModel translate(ImageModel source, {int dx = 0, int dy = 0}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    final translated = img.Image.from(srcImage);

    // Buat gambar kosong
    for (var y = 0; y < translated.height; y++) {
      for (var x = 0; x < translated.width; x++) {
        translated.setPixel(x, y, img.ColorRgb8(0, 0, 0));
      }
    }

    // Salin dengan translasi
    for (var y = 0; y < srcImage.height; y++) {
      for (var x = 0; x < srcImage.width; x++) {
        final newX = x + dx;
        final newY = y + dy;

        if (newX >= 0 &&
            newX < srcImage.width &&
            newY >= 0 &&
            newY < srcImage.height) {
          translated.setPixel(newX, newY, srcImage.getPixel(x, y));
        }
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(translated));

    return source.copyWith(
      processedImage: translated,
      processedBytes: processedBytes,
    );
  }

  // Rotasi
  static ImageModel rotate(ImageModel source, {double angle = 0}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    final rotated = img.copyRotate(srcImage, angle: angle);
    final processedBytes = Uint8List.fromList(img.encodePng(rotated));

    return source.copyWith(
      processedImage: rotated,
      processedBytes: processedBytes,
    );
  }

  // Scaling
  static ImageModel scale(ImageModel source, {double factor = 1.0}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    final scaled = img.copyResize(
      srcImage,
      width: (srcImage.width * factor).round(),
      height: (srcImage.height * factor).round(),
    );
    final processedBytes = Uint8List.fromList(img.encodePng(scaled));

    return source.copyWith(
      processedImage: scaled,
      processedBytes: processedBytes,
    );
  }

  // ---------------- Morfologi Citra ----------------
  // Erosi
  static ImageModel applyErosion(ImageModel source, {int iterations = 1}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi manual erosi
    var result = img.Image.from(srcImage);

    for (var iter = 0; iter < iterations; iter++) {
      final temp = img.Image.from(result);

      for (var y = 1; y < srcImage.height - 1; y++) {
        for (var x = 1; x < srcImage.width - 1; x++) {
          // Untuk citra biner (contoh: menggunakan red channel)
          var minValue = 255;

          // Cek 3x3 neighborhood
          for (var ky = -1; ky <= 1; ky++) {
            for (var kx = -1; kx <= 1; kx++) {
              final value = getRed(result.getPixel(x + kx, y + ky));
              minValue = value < minValue ? value : minValue;
            }
          }

          temp.setPixel(x, y, img.ColorRgb8(minValue, minValue, minValue));
        }
      }

      result = temp;
    }

    final processedBytes = Uint8List.fromList(img.encodePng(result));

    return source.copyWith(
      processedImage: result,
      processedBytes: processedBytes,
    );
  }

  // Dilasi
  static ImageModel applyDilation(ImageModel source, {int iterations = 1}) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    // Implementasi manual dilasi
    var result = img.Image.from(srcImage);

    for (var iter = 0; iter < iterations; iter++) {
      final temp = img.Image.from(result);

      for (var y = 1; y < srcImage.height - 1; y++) {
        for (var x = 1; x < srcImage.width - 1; x++) {
          // Untuk citra biner (contoh: menggunakan red channel)
          var maxValue = 0;

          // Cek 3x3 neighborhood
          for (var ky = -1; ky <= 1; ky++) {
            for (var kx = -1; kx <= 1; kx++) {
              final value = getRed(result.getPixel(x + kx, y + ky));
              maxValue = value > maxValue ? value : maxValue;
            }
          }

          temp.setPixel(x, y, img.ColorRgb8(maxValue, maxValue, maxValue));
        }
      }

      result = temp;
    }

    final processedBytes = Uint8List.fromList(img.encodePng(result));

    return source.copyWith(
      processedImage: result,
      processedBytes: processedBytes,
    );
  }

  // Opening (Erosi -> Dilasi)
  static ImageModel applyOpening(ImageModel source, {int iterations = 1}) {
    final eroded = applyErosion(source, iterations: iterations);
    return applyDilation(eroded, iterations: iterations);
  }

  // Closing (Dilasi -> Erosi)
  static ImageModel applyClosing(ImageModel source, {int iterations = 1}) {
    final dilated = applyDilation(source, iterations: iterations);
    return applyErosion(dilated, iterations: iterations);
  }

  // ---------------- Segmentasi Citra ----------------
  // Deteksi Tepi: Sobel
  static ImageModel applySobel(ImageModel source) {
    final srcImage = source.image;
    if (srcImage == null) return source;

    final grayscale = img.grayscale(srcImage);

    // Implementasi manual Sobel
    final edges = img.Image.from(grayscale);

    for (var y = 1; y < grayscale.height - 1; y++) {
      for (var x = 1; x < grayscale.width - 1; x++) {
        // Hitung Sobel X
        final gx = getRed(grayscale.getPixel(x + 1, y - 1)) -
            getRed(grayscale.getPixel(x - 1, y - 1)) +
            2 * getRed(grayscale.getPixel(x + 1, y)) -
            2 * getRed(grayscale.getPixel(x - 1, y)) +
            getRed(grayscale.getPixel(x + 1, y + 1)) -
            getRed(grayscale.getPixel(x - 1, y + 1));

        // Hitung Sobel Y
        final gy = getRed(grayscale.getPixel(x - 1, y - 1)) -
            getRed(grayscale.getPixel(x - 1, y + 1)) +
            2 * getRed(grayscale.getPixel(x, y - 1)) -
            2 * getRed(grayscale.getPixel(x, y + 1)) +
            getRed(grayscale.getPixel(x + 1, y - 1)) -
            getRed(grayscale.getPixel(x + 1, y + 1));

        // Magnitude
        final magnitude =
            sqrt(gx.toDouble() * gx.toDouble() + gy.toDouble() * gy.toDouble())
                .round()
                .clamp(0, 255);
        edges.setPixel(x, y, img.ColorRgb8(magnitude, magnitude, magnitude));
      }
    }

    final processedBytes = Uint8List.fromList(img.encodePng(edges));

    return source.copyWith(
      processedImage: edges,
      processedBytes: processedBytes,
    );
  }

  // Fungsi Helper
  static double sqrt(double value) {
    if (value <= 0) return 0;
    double x = value / 2;
    for (var i = 0; i < 10; i++) {
      x = 0.5 * (x + value / x);
    }
    return x;
  }

  // Pre-defined kernels for edge detection
  static List<List<double>> sobelXKernel = [
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
  ];

  static List<List<double>> sobelYKernel = [
    [-1, -2, -1],
    [0, 0, 0],
    [1, 2, 1]
  ];

  static List<List<double>> prewittXKernel = [
    [-1, 0, 1],
    [-1, 0, 1],
    [-1, 0, 1]
  ];

  static List<List<double>> prewittYKernel = [
    [-1, -1, -1],
    [0, 0, 0],
    [1, 1, 1]
  ];

  static List<List<double>> robertsXKernel = [
    [1, 0],
    [0, -1]
  ];

  static List<List<double>> robertsYKernel = [
    [0, 1],
    [-1, 0]
  ];
}
