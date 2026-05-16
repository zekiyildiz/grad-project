# Smart Municipality System: AI-Supported Environmental and Infrastructure Notification System 🚀 🛰️

An end-to-end, hybrid Cloud-Edge computing solution designed to modernize urban maintenance. This system automates infrastructure hazard reporting by bridging the gap between citizens and local governance through real-time Computer Vision and distributed architecture.

> **TÜBİTAK 2209-A National Grant Recipient** 🎓 ✅  
> Developed as a Graduation Project by Senior Computer Engineering Students at Ankara Yıldırım Beyazıt University (AYBÜ).

## 🏛️ System Architecture & Logic Flow

The system is built on a robust 3-tier hybrid architecture maximizing on-device efficiency and data isolation:
<img width="2816" height="1536" alt="Gemini_Generated_Image_tbzjb7tbzjb7tbzj" src="https://github.com/user-attachments/assets/9dd74782-73e3-47d1-a106-9a6918cb2644" />

## 🏛️ Architectural Overview & System Components
The system is engineered across five distinct specialized layers to ensure maximum scalability, security, and real-time synchronization:

**Client Side (Flutter)**: Manages secure user sessions, coordinates dynamic poll/announcement caching via a custom In-Memory RAM Engine, and efficiently drives the smartphone's camera frame buffer.

**Edge AI Engine (TFLite)**: Executes 100% offline object detection directly on the mobile arm-based processor, completely eliminating recurring server-side GPU infrastructure costs and cloud network latency.

**Backend API Gateway (Node.js & Express)**: Orchestrates incoming multi-part form data streams, processes stateless JSON Web Token (JWT) authentication headers, and utilizes strict Zod DTO schema validation to protect the pipeline.

**Data Isolation Layer (Multer & Firestore)**: Heavy image media streams are caught immediately by Multer Middleware and piped directly onto the server's physical storage disk (/uploads), automatically generating a unique static URI reference. Only lightweight numerical/text metadata and these URIs are written to Cloud Firestore, drastically optimizing database query performance and respecting free-tier Firebase quota limits.

**Role-Based Interaction Loop**: Approved anomaly reports are live-streamed in real-time to both the web-based Admin Dashboard and the mobile Field Worker App. Once a dispatched field worker resolves the physical hazard and marks it as completed, the global state updates instantly, notifying the original citizen and closing the cycle.

## 📊 AI Model & Performance Metrics
The core intelligence of the application relies on an optimized YOLOv8 Nano (YOLOv8n) model structurally trained on a custom municipal urban anomaly dataset across 100 training epochs.

**mAP50 Accuracy**: 97.5% — Demonstrates exceptional high-speed precision in identifying diverse municipal structural hazards.

**mAP50-95 Score**: ~71% — Exceptionally realistic and highly robust against complex, real-world spatial variations, variable shadows, and diverse lighting environments.

**Inference Speed**: 45ms — True zero-latency edge prediction executed seamlessly on standard smartphone hardware.

## 🏷️ Detected Infrastructure Classes (8 Target Anomalies)
Pothole | Garbage Bin (Overflow) | Electrical Panel (Open/Hazard) | Bench (Damaged) | Scooter (Improper Parking) | Traffic Light (Malfunction) | Illegal Poster | Tree (Fallen)

## 🛠️ Tech Stack Specifications
**Frontend & Mobile Ecosystem**: Flutter (Dart) & Provider State Management Architecture

**Backend Infrastructure**: Node.js (TypeScript/JavaScript) & Express.js Micro-Framework

**AI Model / Machine Learning**: YOLOv8n Object Detection & TensorFlow Lite (TFLite)

**Cloud Database & Security**: Firebase Authentication & Google Cloud Firestore (Real-Time Streams)

**Core Dependencies**: Multer (Binary Streaming Middleware) & Zod (Runtime Schema Validation)

## 🚀 Future Work Roadmap
**Identity & Fraud Prevention**: Complete integration of the official Turkish e-Devlet (e-Government) Gateway authentication API to completely eliminate anonymous report spamming and fraudulent hazard declarations.

**Real-Time Push Notification Layer**: Transitioning from pull-based polling mechanics to a native push architecture by implementing Firebase Cloud Messaging (FCM) and APNs for real-time background notification tray updates.

**Stability & APM Deployment**: Integration of industrial Application Performance Monitoring tools like Firebase Crashlytics and Sentry for centralized remote error tracking across heterogeneous iOS and Android devices.

**Advanced Data Persistence**: Offloading dynamic polling and town hall event metrics from transient, volatile In-Memory RAM buckets into permanent, indexed relational cloud records.

## 👥 Project Team & Contributors
Core Software Engineering Team:
Zeynep Üstün — @ZeynepUstunn
Merve Çankaya — @cankayamerve
Zeki Furkan Yıldız — @zekiyildiz

Academic Project Advisor:
Doç. Dr. Muhammed Abdullah Bülbül (Ankara Yıldırım Beyazıt University - Computer Engineering Department)

---
**Developed with ❤️ for smarter, safer, and data-driven modern municipal ecosystems.**
