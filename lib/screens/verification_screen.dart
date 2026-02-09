import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedMaterials;

  const VerificationScreen({super.key, required this.selectedMaterials});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final AuthService authService = AuthService();
  bool _isVerifying = false;

  Future<void> _confirmRecycling() async {
    setState(() {
      _isVerifying = true;
    });

    // Simular o tempo de verificação do coletor (ex: 3 segundos)
    await Future.delayed(const Duration(seconds: 3));

    // Calcular as quantidades para atualizar no Firebase
    int plastic = 0;
    int paper = 0;
    int metal = 0;
    int glass = 0;

    for (var material in widget.selectedMaterials) {
      int quantity = (material['quantity'] as double).toInt(); // Convertendo para int, assumindo unidades inteiras
      switch (material['title']) {
        case 'Plástico':
          plastic = quantity;
          break;
        case 'Papel':
          paper = quantity;
          break;
        case 'Metal':
          metal = quantity;
          break;
        case 'Vidro':
          glass = quantity;
          break;
      }
    }

    // Atualizar no Firebase
    String? error = await authService.atualizarReciclagem(
      plastic: plastic,
      paper: paper,
      metal: metal,
      glass: glass,
    );

    // Note: history entry is written inside authService.atualizarReciclagem()

    setState(() {
      _isVerifying = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar: $error")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reciclagem registrada com sucesso!")),
      );
      // Voltar para a tela anterior ou home
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VERIFICAÇÃO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            const Text(
              'VERIFIQUE OS MATERIAIS SELECIONADOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedMaterials.length,
                itemBuilder: (context, index) {
                  var material = widget.selectedMaterials[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: material['color'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            material['icon'],
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Quantidade: ${material['quantity']} ${material['unit']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 65,
              child: FilledButton(
                onPressed: _isVerifying ? null : _confirmRecycling,
                style: FilledButton.styleFrom(
                  backgroundColor: _isVerifying ? Colors.grey : const Color.fromARGB(255, 15, 64, 19),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CONFIRMAR RECICLAGEM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}