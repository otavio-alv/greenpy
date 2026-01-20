import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'verification_screen.dart';

class SelectMaterialScreen extends StatefulWidget {
  const SelectMaterialScreen({super.key});

  @override
  State<SelectMaterialScreen> createState() => _SelectMaterialScreenState();
}

class _SelectMaterialScreenState extends State<SelectMaterialScreen> {
  final authService = AuthService();
  // Lista para controlar quais materiais estão selecionados
  final List<bool> _selectedMaterials = [false, false, false, false];

  // Controladores para as quantidades (convertidos de double para string apenas para exibição)
  final List<double> _quantities = List.generate(4, (_) => 0.0);
  final List<TextEditingController> _quantityControllers = List.generate(4, (_) => TextEditingController(text: '0'));

  // Unidades para cada material
  final List<String> _units = List.generate(4, (_) => 'unidade');

  @override
  void initState() {
    super.initState();
    // Adiciona listeners aos controladores para atualizar _quantities quando o usuário digitar
    for (int i = 0; i < _quantityControllers.length; i++) {
      _quantityControllers[i].addListener(() {
        _quantities[i] = double.tryParse(_quantityControllers[i].text) ?? 0.0;
      });
    }
  }

  void _incrementQuantity(int index) {
    _quantities[index] += 1;
    _quantityControllers[index].text = _quantities[index].toString();
  }

  void _decrementQuantity(int index) {
    if (_quantities[index] > 0) {
      _quantities[index] -= 1;
      _quantityControllers[index].text = _quantities[index].toString();
    }
  }

  void _changeUnit(int index, String newUnit) {
    setState(() {
      _units[index] = newUnit;
    });
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
          'SELECIONE O MATERIAL',
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
          children: [

            const Text(
              'SELECIONE O MATERIAL QUE IRÁ DESCARTAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Lista de materiais
            Expanded(
              child: ListView(
                children: [
                  // Plástico
                  MaterialCard(
                    icon: Icons.recycling,
                    color: Colors.red,
                    title: 'Plástico',
                    description: 'Garrafas PET, frascos de shampoo, embalagens de produtos de limpeza...',
                    isSelected: _selectedMaterials[0],
                    quantityController: _quantityControllers[0],
                    unit: _units[0],
                    onUnitChanged: (newUnit) => _changeUnit(0, newUnit),
                    onIncrement: () => _incrementQuantity(0),
                    onDecrement: () => _decrementQuantity(0),
                    onTap: () {
                      setState(() {
                        _selectedMaterials[0] = !_selectedMaterials[0];
                        if (_selectedMaterials[0] && _quantities[0] == 0.0) {
                          _quantities[0] = 1.0;
                          _quantityControllers[0].text = '1';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Papel
                  MaterialCard(
                    icon: Icons.description,
                    color: const Color.fromARGB(255, 45, 61, 207),
                    title: 'Papel',
                    description: 'Papéis comuns, jornais, papelão, revistas de produtos...',
                    isSelected: _selectedMaterials[1],
                    quantityController: _quantityControllers[1],
                    unit: _units[1],
                    onUnitChanged: (newUnit) => _changeUnit(1, newUnit),
                    onIncrement: () => _incrementQuantity(1),
                    onDecrement: () => _decrementQuantity(1),
                    onTap: () {
                      setState(() {
                        _selectedMaterials[1] = !_selectedMaterials[1];
                        if (_selectedMaterials[1] && _quantities[1] == 0.0) {
                          _quantities[1] = 1.0;
                          _quantityControllers[1].text = '1';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Metal
                  MaterialCard(
                    icon: Icons.local_drink,
                    color: const Color.fromARGB(255, 215, 181, 56),
                    title: 'Metal',
                    description: 'Latinhas de bebida, latas de conserva, utensílios...',
                    isSelected: _selectedMaterials[2],
                    quantityController: _quantityControllers[2],
                    unit: _units[2],
                    onUnitChanged: (newUnit) => _changeUnit(2, newUnit),
                    onIncrement: () => _incrementQuantity(2),
                    onDecrement: () => _decrementQuantity(2),
                    onTap: () {
                      setState(() {
                        _selectedMaterials[2] = !_selectedMaterials[2];
                        if (_selectedMaterials[2] && _quantities[2] == 0.0) {
                          _quantities[2] = 1.0;
                          _quantityControllers[2].text = '1';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Vidro
                  MaterialCard(
                    icon: Icons.wine_bar,
                    color: Colors.green,
                    title: 'Vidro',
                    description: 'Garrafas, potes de conserva, frascos, pratos, copos...',
                    isSelected: _selectedMaterials[3],
                    quantityController: _quantityControllers[3],
                    unit: _units[3],
                    onUnitChanged: (newUnit) => _changeUnit(3, newUnit),
                    onIncrement: () => _incrementQuantity(3),
                    onDecrement: () => _decrementQuantity(3),
                    onTap: () {
                      setState(() {
                        _selectedMaterials[3] = !_selectedMaterials[3];
                        if (_selectedMaterials[3] && _quantities[3] == 0.0) {
                          _quantities[3] = 1.0;
                          _quantityControllers[3].text = '1';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botão Continuar
            SizedBox(
              width: double.infinity,
              height: 65,
              child: FilledButton(
                onPressed: _selectedMaterials.contains(true)
                    ? () {
                        // Coletar materiais selecionados e quantidades
                        List<Map<String, dynamic>> selectedMaterials = [];
                        List<Map<String, dynamic>> materials = [
                          {'title': 'Plástico', 'icon': Icons.recycling, 'color': Colors.red},
                          {'title': 'Papel', 'icon': Icons.description, 'color': const Color.fromARGB(255, 45, 61, 207)},
                          {'title': 'Metal', 'icon': Icons.local_drink, 'color': const Color.fromARGB(255, 215, 181, 56)},
                          {'title': 'Vidro', 'icon': Icons.wine_bar, 'color': Colors.green},
                        ];
                        for (int i = 0; i < _selectedMaterials.length; i++) {
                          if (_selectedMaterials[i]) {
                            selectedMaterials.add({
                              'title': materials[i]['title'],
                              'icon': materials[i]['icon'],
                              'color': materials[i]['color'],
                              'quantity': _quantities[i],
                              'unit': _units[i],
                            });
                          }
                        }
                        // Navegar para a tela de verificação
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerificationScreen(selectedMaterials: selectedMaterials),
                          ),
                        );
                      }
                    : null, // Desabilita se nenhum material estiver selecionado
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 15, 64, 19),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'CONTINUAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: _selectedMaterials.contains(true) 
                        ? Colors.white 
                        : Colors.grey[500],
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

// ============================================================================
// MATERIAL CARD
// ============================================================================

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.quantityController,
    required this.unit,
    required this.onUnitChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final TextEditingController quantityController;
  final String unit;
  final Function(String) onUnitChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            // Ícone colorido
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: onDecrement,
                          icon: Icon(Icons.remove, color: color),
                        ),
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            decoration: InputDecoration(
                              labelText: 'Quantidade',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            ),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: onIncrement,
                          icon: Icon(Icons.add, color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: unit,
                      items: ['unidade', 'kg'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          onUnitChanged(newValue);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? color : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}