import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageModel {
  final Uint8List originalBytes;
  final Uint8List? processedBytes;
  final String? name;
  final String? path;
  final img.Image? image;
  final img.Image? processedImage;
  final Map<String, dynamic>? metadata;
  final List<HistoryItem>? history;

  ImageModel({
    required this.originalBytes,
    this.processedBytes,
    this.name,
    this.path,
    this.image,
    this.processedImage,
    this.metadata,
    this.history,
  });

  ImageModel copyWith({
    Uint8List? originalBytes,
    Uint8List? processedBytes,
    String? name,
    String? path,
    img.Image? image,
    img.Image? processedImage,
    Map<String, dynamic>? metadata,
    List<HistoryItem>? history,
  }) {
    return ImageModel(
      originalBytes: originalBytes ?? this.originalBytes,
      processedBytes: processedBytes ?? this.processedBytes,
      name: name ?? this.name,
      path: path ?? this.path,
      image: image ?? this.image,
      processedImage: processedImage ?? this.processedImage,
      metadata: metadata ?? this.metadata,
      history: history ?? this.history,
    );
  }

  factory ImageModel.fromFile(File file) {
    final bytes = file.readAsBytesSync();
    final name = file.path.split('/').last;
    final path = file.path;
    final image = img.decodeImage(bytes);

    return ImageModel(
      originalBytes: bytes,
      name: name,
      path: path,
      image: image,
    );
  }

  factory ImageModel.fromBytes(Uint8List bytes, {String? name}) {
    final image = img.decodeImage(bytes);

    return ImageModel(
      originalBytes: bytes,
      name: name,
      image: image,
    );
  }
}

class HistoryItem {
  final String operation;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final Uint8List? resultImage;

  HistoryItem({
    required this.operation,
    required this.parameters,
    required this.timestamp,
    this.resultImage,
  });
}
