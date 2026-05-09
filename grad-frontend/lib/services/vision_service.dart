import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui; // Required for image decoding

class VisionService {
  late FlutterVision vision;
  bool isLoaded = false;

  VisionService() {
    vision = FlutterVision();
  }

  // 1. Model Loading Function
  Future<void> loadModel() async {
    if (!isLoaded) {
      await vision.loadYoloModel(
        modelPath: 'assets/model/best_float32.tflite', // Model file
        labels: 'assets/model/labels.txt', // Label file
        modelVersion: "yolov8", // Standard for YOLOv8 models
        quantization: false, // Since we're using float32, false
        numThreads: 1, // CPU usage setting
        useGpu:
            false, // Use the mobile GPU (may sometimes cause errors; setting to false is safe)
      );
      isLoaded = true;
      print("Yapay Zeka Modeli Yüklendi! 🚀");
    }
  }

  // 2. Photo Analysis Feature
  Future<List<Map<String, dynamic>>> runInference(XFile imageFile) async {
    // Convert the image to byte format
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Decode the image (to get its dimensions)
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    final imageHeight = frameInfo.image.height;
    final imageWidth = frameInfo.image.width;

    print("🚀🚀🚀 DİKKAT: YENİ KOD VE YENİ MODEL ÇALIŞIYOR! EŞİK 0.20 🚀🚀🚀");
    // Start the prediction process
    final result = await vision.yoloOnImage(
      bytesList: imageBytes,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      iouThreshold: 0.45, // Box collision sensitivity
      confThreshold: 0.4, // Confidence threshold 
    );

    if (result.isNotEmpty) {
      print("Tespit Edilen Nesneler: $result");
    } else {
      print("Hiçbir nesne tespit edilemedi.");
    }

    return result;
  }

  // 3. Closing the Model (Memory Cleanup)
  Future<void> closeModel() async {
    if (isLoaded) {
      await vision.closeYoloModel();
      isLoaded = false;
    }
  }
}
