import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController controller;
  late ImageLabeler _labeler;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      returnImage: true,
    );

    _labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));
  }

  @override
  void dispose() {
    controller.dispose();
    _labeler.close();
    super.dispose();
  }

  String _mapMLToCategory(List<ImageLabel> labels) {
    if (labels.isEmpty) return "PANTRY";

    for (var label in labels) {
      final text = label.label.toLowerCase();

      if (text.contains('snack') || 
          text.contains('confectionery') || 
          text.contains('chocolate') || 
          text.contains('choco') ||
          text.contains('tie') ||
          text.contains('candy') || 
          text.contains('sweets') ||
          text.contains('cookie') ||
          text.contains('wafer')) {
        return "SWEETS";
      }

      if (text.contains('beverage') || text.contains('drink') || text.contains('water') || text.contains('bottle')) {
        return "BEVERAGE";
      }

      if (text.contains('fruit') || text.contains('vegetable') || text.contains('food')) {
        if (label.confidence > 0.7) return "VEGETABLE";
      }
    }

    return "PANTRY";
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;
    

    final List<Barcode> barcodes = capture.barcodes;
    final Uint8List? imageBytes = capture.image;

    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isProcessing = true);
      final String code = barcodes.first.rawValue!;
      String aiCategory = "SWEETS";

      try {
        if (imageBytes != null) {
          final tempDir = await getTemporaryDirectory();
          final String filePath = '${tempDir.path}/ml_kit_frame.jpg';
          
          final File imageFile = File(filePath);
          await imageFile.writeAsBytes(imageBytes);

          final inputImage = InputImage.fromFilePath(filePath);

          final List<ImageLabel> labels = await _labeler.processImage(inputImage);
          for (var label in labels) {
            debugPrint('AI Label Found: ${label.label} (Confidence: ${label.confidence})');
          }
          aiCategory = _mapMLToCategory(labels);
          
          if (await imageFile.exists()) await imageFile.delete();
        }
      } catch (e) {
        debugPrint("AI Processing Error: $e");
      }

      if (mounted) {
        if (context.read<AuthProvider>().hapticsEnabled) HapticFeedback.mediumImpact();
        Navigator.pop(context, {
          'barcode': code,
          'aiCategory': aiCategory,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final highContrast = authProvider.highContrast;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color contrastColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan Product Barcode", 
          style: TextStyle(color: highContrast ? contrastColor : (isDark ? Colors.white70 : Colors.black54))), 
          backgroundColor: highContrast ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.black26 : Colors.white70
        ),
        iconTheme: IconThemeData(
          color: highContrast 
              ? contrastColor 
              : (isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleDetection,
          ),
          _buildScannerOverlay(highContrast, contrastColor),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(bool highContrast, Color contrastColor) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(color: Colors.black),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: highContrast ? contrastColor : Colors.greenAccent,
                width: highContrast ? 4 : 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}