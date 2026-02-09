import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      return double.tryParse(v);
    }
    return null;
  }

  LatLng _getLatLng(Map<String, dynamic> ponto) {
    final lat = _toDouble(ponto['lat'] ?? ponto['latitude']);
    final lng = _toDouble(ponto['lng'] ?? ponto['longitude']);
    if (lat != null && lng != null) return LatLng(lat, lng);
    return _center;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('partners').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawDocs = snapshot.data?.docs ?? [];

          // Filtra localmente apenas os parceiros que possuem dados de endereço ou coordenadas
          final pontos = rawDocs.where((d) {
            final data = d.data();
            final address = (data['address'] ?? data['endereco'] ?? '')?.toString();
            final hasAddress = address != null && address.isNotEmpty;
            final hasLatLng = (data['lat'] != null && data['lng'] != null) || (data['latitude'] != null && data['longitude'] != null);
            return hasAddress || hasLatLng;
          }).toList();

          if (pontos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 48, color: Colors.white70),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum ponto de coleta disponível',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
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
                _buildMainMapCard(pontos[0].data()),
                
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
                ...pontos.skip(1).map((doc) => _buildLocationItem(doc.data())).toList(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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
                  initialCameraPosition: CameraPosition(target: _getLatLng(ponto), zoom: 15),
                  markers: {
                    Marker(
                      markerId: const MarkerId('main_point'),
                      position: _getLatLng(ponto),
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
                "${ponto['name'] ?? ponto['nome'] ?? 'Ponto de Coleta'}${ponto['distancia'] != null ? ' (${ponto['distancia']})' : ''}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(ponto['address'] ?? ponto['endereco'] ?? ''),
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
          "${ponto['name'] ?? ponto['nome'] ?? 'Ponto de Coleta'}${ponto['distancia'] != null ? ' (${ponto['distancia'].toString()})' : ''}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          ponto['address'] ?? ponto['endereco'] ?? '',
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