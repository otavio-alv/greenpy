import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  
  // Autenticação
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Cadastro
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController(); // Controlador do sobrenome

  bool _isLogin = true;     // true = login | false = cadastro
  bool _isLoading = false;

  void _submitForm() async {
    setState(() => _isLoading = true);
    String? erro;

    if (_isLogin) {
      // Login
      erro = await _authService.loginUsuario(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      // Cadastro
      erro = await _authService.cadastrarUsuario(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        surname: _surnameController.text,
      );
    }

    setState(() => _isLoading = false);

    if (erro != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Bem-vindo de volta!' : 'Conta criada com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Aguarda um pouco para o Firebase processar o login
      await Future.delayed(const Duration(milliseconds: 500));

      // Verifica se o usuário é admin
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email ?? '';
      final localPart = email.split('@').first;
      final isAdmin = localPart.toLowerCase().contains('admin');

      if (mounted) {
        if (isAdmin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminDashboard(adminEmail: email)),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliza do tema universal do app
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(  // Scaffold é a estrutura de tela principal do M3
      backgroundColor: colorScheme.surface,

      body: Center(   // Define para os widgets estarem centralizado
        child: SingleChildScrollView(   // Define uma tela única scrollável
          padding: const EdgeInsets.all(24.0),    // Padding (espaço ao redor)
          child: Column(    // Organiza os elementos em coluna (um embaixo do outro)
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,   // Define a organização dos widgets na coluna
            children: [
              IconBox(colorScheme: colorScheme),    // Widget do ícone
              const SizedBox(height: 32),

              // Texto de Introdução
              PresentText(isLogin: _isLogin, textTheme: textTheme, colorScheme: colorScheme),
              const SizedBox(height: 32),

              // Campos de nome e sobrenome para cadastro
              if (!_isLogin) ...[
                NameField(nameController: _nameController),
                const SizedBox(height: 16),

                SurnameField(surnameController: _surnameController),
                const SizedBox(height: 16),
              ],

              // Campos de email e senha
              EmailField(emailController: _emailController),
              const SizedBox(height: 16),

              PassField(passwordController: _passwordController),
              const SizedBox(height: 32),

              // Botão de Autenticação
              AuthButton(
                isLogin: _isLogin,
                isLoading: _isLoading,
                onPressed: _submitForm, 
              ),
              const SizedBox(height: 24),

              // Texto de conta ou login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? 'Ainda não tem conta?' : 'Já tem uma conta?',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Limpa os campos de nome se formos para a tela de login
                        if (_isLogin) {
                          _nameController.clear();
                          _surnameController.clear();
                        }
                      });
                    },
                    child: Text(
                      _isLogin ? 'Cadastre-se' : 'Faça Login',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === WIDGETS ===

class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.eco_rounded,
          size: 60,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class PresentText extends StatelessWidget {
  const PresentText({
    super.key,
    required bool isLogin,
    required this.textTheme,
    required this.colorScheme,
  }) : _isLogin = isLogin;

  final bool _isLogin;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _isLogin ? 'Bem-vindo ao Greenpy' : 'Crie sua conta',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin 
            ? 'Recicle e ganhe pontos.' 
            : 'Comece a mudar o mundo hoje.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required TextEditingController nameController,
  }) : _nameController = nameController;

  final TextEditingController _nameController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome',
        prefixIcon: Icon(Icons.person_outline),
      ),
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words, // Deixa a primeira letra maiúscula
    );
  }
}

class SurnameField extends StatelessWidget {
  const SurnameField({
    super.key,
    required TextEditingController surnameController,
  }) : _surnameController = surnameController;

  final TextEditingController _surnameController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _surnameController,
      decoration: const InputDecoration(
        labelText: 'Sobrenome',
        prefixIcon: Icon(Icons.person_add_alt_1_outlined),
      ),
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    );
  }
}

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required TextEditingController emailController,
  }) : _emailController = emailController;

  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'E-mail',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}

class PassField extends StatelessWidget {
  const PassField({
    super.key,
    required TextEditingController passwordController,
  }) : _passwordController = passwordController;

  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Senha',
        prefixIcon: Icon(Icons.lock_outline),
      ),
      obscureText: true,
    );
  }
}

class AuthButton extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final VoidCallback onPressed; 

  const AuthButton({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        // Se estiver carregando, botão nulo (desativado). 
        // Se não, usa a função que recebemos (onPressed).
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isLogin ? 'ENTRAR' : 'CADASTRAR',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}