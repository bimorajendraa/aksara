import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraCaptureOCRPage extends StatefulWidget {
  const CameraCaptureOCRPage({super.key});

  @override
  State<CameraCaptureOCRPage> createState() => _CameraCaptureOCRPageState();
}

class _CameraCaptureOCRPageState extends State<CameraCaptureOCRPage> {
  CameraController? _cameraController;
  late TextRecognizer _textRecognizer;

  bool _isLoading = false;
  File? _capturedImage;

  String ocrText = "";
  String syllableText = "";

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final XFile image = await _cameraController!.takePicture();

    setState(() {
      _capturedImage = File(image.path);
      ocrText = "";
      syllableText = "";
    });

    _runOCR();
  }

  Future<void> _runOCR() async {
    if (_capturedImage == null) return;

    setState(() => _isLoading = true);

    final inputImage = InputImage.fromFile(_capturedImage!);
    final result = await _textRecognizer.processImage(inputImage);

    String text = result.text.trim();
    ocrText = text;

    syllableText = _splitIntoSyllables(text.toLowerCase());

    setState(() => _isLoading = false);
  }

  String _splitIntoSyllables(String text) {
    final vowels = ['a', 'i', 'u', 'e', 'o'];
    List<String> words = text.split(" ");
    List<String> finalWords = [];

    for (var w in words) {
      if (w.isEmpty) continue;

      List<String> parts = [];
      String buffer = "";

      for (int i = 0; i < w.length; i++) {
        buffer += w[i];

        if (vowels.contains(w[i])) {
          parts.add(buffer);
          buffer = "";
        }
      }

      if (buffer.isNotEmpty) {
        parts.add(buffer);
      }

      finalWords.add(parts.join(" - "));
    }

    return finalWords.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _capturedImage == null
                ? _buildCaptureButton()
                : _buildResultCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 40),
      child: GestureDetector(
        onTap: _captureImage,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 5),
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // RESULT CARD (SCROLLABLE)
  // ---------------------------
  Widget _buildResultCard(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.48, // RESPONSIVE
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_up_rounded, size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ocrText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Suku Kata:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    syllableText,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _capturedImage = null);
                      },
                      child: const Text("Ambil Foto Lagi"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
