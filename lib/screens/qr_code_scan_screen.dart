import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_code_confirmation_screen.dart';
import 'qr_code_recycle_confirmation_screen.dart';

class QrCodeScanScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? selectedMaterials;
  final bool isRecycle;

  const QrCodeScanScreen({super.key, this.selectedMaterials, this.isRecycle = false});

  @override
  State<QrCodeScanScreen> createState() => _QrCodeScanScreenState();
}

class _QrCodeScanScreenState extends State<QrCodeScanScreen> {
  late MobileScannerController _scannerController;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _handleQrCode(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanned = true;
        _navigateToConfirmation(barcode.rawValue!);
        break;
      }
    }
  }

  void _navigateToConfirmation(String qrValue) {
    if (widget.isRecycle && widget.selectedMaterials != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrCodeRecycleConfirmationScreen(
            qrValue: qrValue,
            selectedMaterials: widget.selectedMaterials!,
          ),
        ),
      ).then((_) {
        setState(() {
          _isScanned = false;
        });
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrCodeConfirmationScreen(
            qrValue: qrValue,
            rewardType: 'Desconto em Transporte',
            pointsCost: 50,
          ),
        ),
      ).then((_) {
        // Reseta o estado quando volta
        setState(() {
          _isScanned = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Escanear QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleQrCode,
          ),

          // Overlay com frame
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Simula a leitura de um QR code ao tocar no quadrado
                _handleQrCode(
                  BarcodeCapture(
                    barcodes: [
                      Barcode(
                        rawValue: 'QR_CODE_SIMULADO_${DateTime.now().millisecondsSinceEpoch}',
                      ),
                    ],
                  ),
                );
              },
              child: CustomPaint(
                painter: QrOverlayPainter(colorScheme.primary),
              ),
            ),
          ),

          // Instrução
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Text(
                      'Aponte a câmera para o QR Code do estabelecimento',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão de flash
          Positioned(
            top: 120,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.flash_on, color: Colors.white),
                onPressed: () {
                  _scannerController.toggleTorch();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrOverlayPainter extends CustomPainter {
  final Color frameColor;
  QrOverlayPainter(this.frameColor);

  @override
  void paint(Canvas canvas, Size size) {
    const qrFrameSize = 250.0;
    final dx = (size.width - qrFrameSize) / 2;
    final dy = (size.height - qrFrameSize) / 2;

    // Desenhar overlay escuro
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.4),
    );

    // Limpar área do QR
    canvas.drawRect(
      Rect.fromLTWH(dx, dy, qrFrameSize, qrFrameSize),
      Paint()..color = Colors.transparent..blendMode = BlendMode.clear,
    );

    // Desenhar frame
    final paint = Paint()
      ..color = frameColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(dx, dy, qrFrameSize, qrFrameSize),
      paint,
    );

    // Desenhar cantos
    const cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = frameColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Canto superior esquerdo
    canvas.drawPath(
      Path()
        ..moveTo(dx, dy + cornerLength)
        ..lineTo(dx, dy)
        ..lineTo(dx + cornerLength, dy),
      cornerPaint,
    );

    // Canto superior direito
    canvas.drawPath(
      Path()
        ..moveTo(dx + qrFrameSize - cornerLength, dy)
        ..lineTo(dx + qrFrameSize, dy)
        ..lineTo(dx + qrFrameSize, dy + cornerLength),
      cornerPaint,
    );

    // Canto inferior esquerdo
    canvas.drawPath(
      Path()
        ..moveTo(dx, dy + qrFrameSize - cornerLength)
        ..lineTo(dx, dy + qrFrameSize)
        ..lineTo(dx + cornerLength, dy + qrFrameSize),
      cornerPaint,
    );

    // Canto inferior direito
    canvas.drawPath(
      Path()
        ..moveTo(dx + qrFrameSize - cornerLength, dy + qrFrameSize)
        ..lineTo(dx + qrFrameSize, dy + qrFrameSize)
        ..lineTo(dx + qrFrameSize, dy + qrFrameSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(QrOverlayPainter oldDelegate) => false;
}
