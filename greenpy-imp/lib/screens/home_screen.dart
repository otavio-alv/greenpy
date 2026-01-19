import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

/// Tela principal do aplicativo após login.
/// Exibe dados do usuário (pontos, materiais reciclados) e navegação para outras telas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  int _currentIndex = 0; // Índice da aba selecionada na navegação inferior

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // StreamBuilder para atualizar a UI automaticamente com mudanças nos dados do usuário
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: authService.streamDadosUsuario(),
      builder: (context, snapshot) {
        // Estado de carregamento inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Erro ao carregar dados
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Scaffold(
            body: Center(
              child: Text("Erro ao carregar dados"),
            ),
          );
        }

        // Dados do usuário extraídos do snapshot
        final Map<String, dynamic> dados = snapshot.data!.data()!;
        final String nomeReal = dados['name'] ?? 'Reciclador';
        final int pontosReais = dados['points'] ?? 0;
        final List<int> itensReais = [
          dados['plastic'] ?? 0,
          dados['paper'] ?? 0,
          dados['metal'] ?? 0,
          dados['glass'] ?? 0,
        ];

        // Lista de páginas para navegação inferior
        final List<Widget> pages = [
          HomePage(pontos: pontosReais, itens: itensReais), // Página inicial
          const RecycleScreen(), // Página de reciclagem
          const Center(child: Text("Tela de Prêmios")), // Placeholder
        ];

        return Scaffold(
          backgroundColor: colorScheme.primary,
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            centerTitle: false,
            title: _currentIndex == 0
                ? AppBarTitle(colorScheme: colorScheme, nome: nomeReal)
                : Text(
                    _currentIndex == 1 ? 'REGISTRE SEU DESCARTE' : 'USE SEUS PONTOS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            actions: _currentIndex == 0
                ? [
                    IconButton(
                      icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ]
                : null,
          ),

          body: pages[_currentIndex], // Corpo da tela baseado na aba selecionada

          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
              NavigationDestination(icon: Icon(Icons.eco_outlined), label: 'Reciclar'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: 'Usar pontos'),
            ],
          ),
        );
      },
    );
  }
}


/// Página inicial exibida na aba "Início".
/// Mostra resumo dos pontos e materiais reciclados, além de botões para ações 
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.pontos,
    required this.itens,
  });

  final int pontos; // Pontos acumulados pelo usuário
  final List<int> itens; // Lista com quantidades recicladas [plástico, papel, metal, vidro]

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Caixa exibindo os pontos do usuário
            InfoPontos(pontos: pontos),
            const SizedBox(height: 15),

            // Caixa exibindo os materiais reciclados
            ItensBox(itens: itens),
            const SizedBox(height: 15),

            // Botões de ação para navegação rápida
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GreenpySquareButton(
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CollectionPointsScreen(),
                      ),
                    );
                  },
                  text: 'Pontos\nde Coleta',
                ),
                const SizedBox(width: 25),
                GreenpySquareButton(
                  icon: Icons.shopping_cart_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CollectionPointsScreen(),
                      ),
                    );
                  },
                  text: 'Loja\nSustentável',
                ),
                const SizedBox(width: 25),
                GreenpySquareButton(
                  icon: Icons.info_outline_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HowToRecycleScreen(),
                      ),
                    );
                  },
                  text: 'Como\nreciclar',
                ),
                const SizedBox(width: 25),
                GreenpySquareButton(
                  icon: Icons.receipt_long_outlined,
                  onTap: () {},
                  text: 'Extrato\n ',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que exibe os pontos acumulados pelo usuário em um card estilizado.
class InfoPontos extends StatelessWidget {
  const InfoPontos({
    super.key,
    required this.pontos,
  });

  final int pontos; // Pontos totais do usuário

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pontos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            Text(
              '$pontos',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 50,
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.start,
            ),
            const Text(
              'Você já economizou:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            const Text(
              'R\$ 15,00',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 50,
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


/// Widget que exibe um resumo dos materiais reciclados pelo usuário.
/// Mostra ícones e quantidades para plástico, papel, metal e vidro.
class ItensBox extends StatelessWidget {
  const ItensBox({
    super.key,
    required this.itens,
  });

  final List<int> itens; // Lista [plástico, papel, metal, vidro]

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lixos reciclados por você!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plástico
                ItenWidget(
                  color: Colors.red,
                  icon: Icons.recycling,
                  qtd: itens[0],
                ),
                const SizedBox(width: 7),

                // Papel
                ItenWidget(
                  color: const Color.fromARGB(255, 45, 61, 207),
                  icon: Icons.description,
                  qtd: itens[1],
                ),
                const SizedBox(width: 7),

                // Metal
                ItenWidget(
                  color: const Color.fromARGB(255, 215, 181, 56),
                  icon: Icons.local_drink,
                  qtd: itens[2],
                ),
                const SizedBox(width: 7),

                // Vidro
                ItenWidget(
                  color: Colors.green,
                  icon: Icons.wine_bar,
                  qtd: itens[3],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ItenWidget extends StatelessWidget {
  const ItenWidget({
    super.key,
    required this.icon,
    required this.qtd,
    required this.color,
  });

  final IconData icon;
  final int qtd;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: 70,
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
              color: Colors.white,
            ),
            Text(
              ' $qtd',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    super.key,
    required this.colorScheme,
    required this.nome,
  });

  final ColorScheme colorScheme;
  final String nome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GREENPY',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          'Bem vindo, $nome!',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Botão quadrado personalizado usado para ações rápidas na tela inicial.
/// Exibe um ícone e texto, com callback para ação ao tocar.
class GreenpySquareButton extends StatelessWidget {
  const GreenpySquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.text,
  });

  final IconData icon; // Ícone exibido no botão
  final VoidCallback onTap; // Função chamada ao tocar no botão
  final String text; // Texto exibido abaixo do ícone

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
