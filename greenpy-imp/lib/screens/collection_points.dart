import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'collection_point_detail.dart';

class CollectionPointsScreen extends StatefulWidget {
  const CollectionPointsScreen({super.key});

  @override
  State<CollectionPointsScreen> createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends State<CollectionPointsScreen> {
  // Coordenada inicial (Ouro Preto como exemplo)
  static const LatLng _center = LatLng(-20.3855, -43.5035);
  
  // Lista fictícia de pontos para simular o banco de dados
  final List<Map<String, dynamic>> _pontos = [
    {
      'nome': 'Supermercado Itacolomy',
      'distancia': '500m',
      'endereco': 'Av. Juscelino Kubitscheck, 720 - Vila Itacolomy, Ouro Preto - MG',
      'lat': -20.3855,
      'lng': -43.5035,
    },
    {
      'nome': 'Escola de Minas',
      'distancia': '750m',
      'endereco': 'R. Nove, 293 - Bauxita, Ouro Preto - MG',
      'lat': -20.3890,
      'lng': -43.5010,
    },
    {
      'nome': 'Supermercado EPA',
      'distancia': '1km',
      'endereco': 'Av. Juscelino Kubitscheck, 91 - Vila Itacolomy, Ouro Preto - MG',
      'lat': -20.3865,
      'lng': -43.5050,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary, // Fundo verde
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PONTO DE COLETA PRÓXIMO A VOCÊ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Card Principal com o Mapa
            _buildMainMapCard(_pontos[0]),
            
            const SizedBox(height: 32),
            const Text(
              'Mais pontos de coleta:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de outros pontos
            ..._pontos.skip(1).map((ponto) => _buildLocationItem(ponto)).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMapCard(Map<String, dynamic> ponto) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionPointDetailScreen(point: ponto),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Área do Mapa
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: _center, zoom: 15),
                  markers: {
                    Marker(
                      markerId: const MarkerId('main_point'),
                      position: LatLng(ponto['lat'], ponto['lng']),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
            // Informações do ponto
            ListTile(
              title: Text(
                "${ponto['nome']} (${ponto['distancia']})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(ponto['endereco']),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> ponto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32), // Tom de verde escuro para o ícone
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.location_on, color: Colors.white),
        ),
        title: Text(
          "${ponto['nome']} (${ponto['distancia']})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          ponto['endereco'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollectionPointDetailScreen(point: ponto),
            ),
          );
        },
      ),
    );
  }
}