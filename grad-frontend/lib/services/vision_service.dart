import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui; // Resim decode işlemi için gerekli

class VisionService {
  late FlutterVision vision;
  bool isLoaded = false;

  VisionService() {
    vision = FlutterVision();
  }

  // 1. Modeli Yükleme Fonksiyonu
  Future<void> loadModel() async {
    if (!isLoaded) {
      await vision.loadYoloModel(
        modelPath: 'assets/model/best_float32.tflite', // Model dosyan
        labels: 'assets/model/labels.txt', // Etiket dosyan
        modelVersion: "yolov8", // YOLOv8/v11 modelleri için standart
        quantization: false, // float32 kullandığımız için false
        numThreads: 1, // İşlemci kullanım ayarı
        useGpu:
            false, // Mobil GPU kullanımı (bazen hata verebilir, false güvenlidir)
      );
      isLoaded = true;
      print("Yapay Zeka Modeli Yüklendi! 🚀");
    }
  }

  // 2. Fotoğraf Analiz Fonksiyonu
  Future<List<Map<String, dynamic>>> runInference(XFile imageFile) async {
    // Görseli byte formatına çevir
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Resmi decode et (Boyutlarını almak için)
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    final imageHeight = frameInfo.image.height;
    final imageWidth = frameInfo.image.width;

    // Tahmin işlemini başlat
    final result = await vision.yoloOnImage(
      bytesList: imageBytes,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      iouThreshold: 0.45, // Kutu çakışma hassasiyeti
      confThreshold: 0.40, // Güven eşiği (%40 altını görmezden gel)
    );

    if (result.isNotEmpty) {
      print("Tespit Edilen Nesneler: $result");
    } else {
      print("Hiçbir nesne tespit edilemedi.");
    }

    return result;
  }

  // 3. Modeli Kapatma (Bellek Temizliği)
  Future<void> closeModel() async {
    if (isLoaded) {
      await vision.closeYoloModel();
      isLoaded = false;
    }
  }
}
