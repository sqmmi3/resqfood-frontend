import 'package:flutter/material.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      returnImage: true,
    );
  }

  void _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() => _isProcessing = true);

    await controller.stop();

    if (!mounted) return;

    Navigator.pop(context, {
      'barcode': barcode
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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