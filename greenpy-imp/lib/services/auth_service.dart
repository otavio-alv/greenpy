import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço responsável por gerenciar a autenticação e dados do usuário no Firebase.
/// Fornece métodos para cadastro, login, logout, atualização de dados de reciclagem
/// e exclusão de conta.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cadastra um novo usuário no Firebase Auth e Firestore.
  /// [email]: Email do usuário.
  /// [password]: Senha do usuário.
  /// [name]: Nome do usuário.
  /// [surname]: Sobrenome do usuário.
  /// Retorna null em caso de sucesso ou uma mensagem de erro.
  Future<String?> cadastrarUsuario({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      // Cria o usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Cria o documento do usuário no Firestore com dados iniciais
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'surname': surname,
        'email': email,
        'points': 0, // Pontos iniciais
        'plastic': 0, // Quantidade de plástico reciclado
        'paper': 0, // Quantidade de papel reciclado
        'glass': 0, // Quantidade de vidro reciclado
        'metal': 0, // Quantidade de metal reciclado
        'createdIn': FieldValue.serverTimestamp(), // Timestamp de criação
      });

      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return e.message; // Erro específico do Firebase Auth
    } catch (e) {
      return "Erro ao salvar dados: ${e.toString()}"; // Erro genérico
    }
  }

  /// Realiza o login do usuário com email e senha.
  /// [email]: Email do usuário.
  /// [password]: Senha do usuário.
  /// Retorna null em caso de sucesso ou uma mensagem de erro.
  Future<String?> loginUsuario(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return e.message; // Erro de autenticação
    }
  }

  /// Faz logout do usuário atual.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Retorna um stream dos dados do usuário logado no Firestore.
  /// Atualiza automaticamente quando os dados mudam.
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDadosUsuario() {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Busca os dados atuais do usuário logado no Firestore.
  /// Retorna um Future com o snapshot do documento.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDadosUsuario() {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).get();
  }

  /// Atualiza os dados de reciclagem do usuário após uma reciclagem.
  /// Calcula pontos ganhos (plástico: 5, papel: 3, metal: 7, vidro: 4 por unidade).
  /// [plastic]: Quantidade de plástico reciclado.
  /// [paper]: Quantidade de papel reciclado.
  /// [metal]: Quantidade de metal reciclado.
  /// [glass]: Quantidade de vidro reciclado.
  /// Retorna null em caso de sucesso ou uma mensagem de erro.
  Future<String?> atualizarReciclagem({
    required int plastic,
    required int paper,
    required int metal,
    required int glass,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference userDoc = _firestore.collection('users').doc(uid);

      // Busca dados atuais do usuário
      DocumentSnapshot doc = await userDoc.get();
      if (!doc.exists) {
        return "Usuário não encontrado";
      }
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Valores atuais
      int currentPoints = data['points'] ?? 0;
      int currentPlastic = data['plastic'] ?? 0;
      int currentPaper = data['paper'] ?? 0;
      int currentMetal = data['metal'] ?? 0;
      int currentGlass = data['glass'] ?? 0;

      // Novos valores após reciclagem
      int newPlastic = currentPlastic + plastic;
      int newPaper = currentPaper + paper;
      int newMetal = currentMetal + metal;
      int newGlass = currentGlass + glass;

      // Calcula pontos ganhos com base nas quantidades recicladas
      int pointsEarned = (plastic * 5) + (paper * 3) + (metal * 7) + (glass * 4);
      int newPoints = currentPoints + pointsEarned;

      // Atualiza o documento no Firestore
      await userDoc.update({
        'plastic': newPlastic,
        'paper': newPaper,
        'metal': newMetal,
        'glass': newGlass,
        'points': newPoints,
      });

      return null; // Sucesso
    } catch (e) {
      return "Erro ao atualizar reciclagem: ${e.toString()}";
    }
  }

  /// Exclui a conta do usuário atual, removendo dados do Firestore e Firebase Auth.
  /// Retorna null em caso de sucesso ou uma mensagem de erro.
  Future<String?> excluirConta() async {
    try {
      String uid = _auth.currentUser!.uid;

      // Remove dados do Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Remove usuário do Firebase Auth
      await _auth.currentUser!.delete();

      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return e.message; // Erro de autenticação
    } catch (e) {
      return e.toString(); // Erro genérico
    }
  }
}