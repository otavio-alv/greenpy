import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class QrCodeRecycleConfirmationScreen extends StatefulWidget {
  final String qrValue;
  final List<Map<String, dynamic>> selectedMaterials;
  final AuthService? authService;

  const QrCodeRecycleConfirmationScreen({super.key, required this.qrValue, required this.selectedMaterials, this.authService});

  @override
  State<QrCodeRecycleConfirmationScreen> createState() => _QrCodeRecycleConfirmationScreenState();
}

class _QrCodeRecycleConfirmationScreenState extends State<QrCodeRecycleConfirmationScreen> {
  late final AuthService _authService;
  bool _isProcessing = false;

  Future<void> _confirmRecycle() async {
    setState(() => _isProcessing = true);

    // Aggregate quantities
    int plastic = 0;
    int paper = 0;
    int metal = 0;
    int glass = 0;

    for (var mat in widget.selectedMaterials) {
      final title = mat['title'] as String? ?? '';
      final qty = (mat['quantity'] as num?)?.toInt() ?? 0;
      switch (title) {
        case 'Plástico':
          plastic += qty;
          break;
        case 'Papel':
          paper += qty;
          break;
        case 'Metal':
          metal += qty;
          break;
        case 'Vidro':
          glass += qty;
          break;
      }
    }

    try {
      final error = await _authService.atualizarReciclagem(
        plastic: plastic,
        paper: paper,
        metal: metal,
        glass: glass,
      );

      if (error != null) {
        _showError('Erro ao registrar', error);
      } else {
        _showSuccess();
      }
    } catch (e) {
      _showError('Erro', e.toString());
    }

    setState(() => _isProcessing = false);
  }

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Reciclagem registrada com sucesso!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.popUntil(context, (route) => route.isFirst); // back to home
                },
                child: const Text('VOLTAR PARA INÍCIO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text('Confirmar Reciclagem'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Center(child: Icon(Icons.recycling, color: Colors.green, size: 48)),
              ),
              const SizedBox(height: 20),
              const Text('Verifique os materiais e confirme o registro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: widget.selectedMaterials.map((mat) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: mat['color'], borderRadius: BorderRadius.circular(8)),
                        child: Icon(mat['icon'], color: Colors.white),
                      ),
                      title: Text(mat['title'] ?? ''),
                      subtitle: Text('Quantidade: ${mat['quantity']} ${mat['unit'] ?? 'kg'}'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _confirmRecycle,
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: colorScheme.primary),
                  child: _isProcessing ? const CircularProgressIndicator() : const Text('CONFIRMAR RECICLAGEM'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
