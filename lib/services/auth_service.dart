import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço responsável por gerenciar a autenticação e dados do usuário no Firebase.
/// Fornece métodos para cadastro, login, logout, atualização de dados de reciclagem
/// e exclusão de conta.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

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
        'points': 0, 
        'plastic': 0.0, 
        'paper': 0.0,   
        'glass': 0.0,   
        'metal': 0.0,   
        'createdIn': FieldValue.serverTimestamp(),
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
    required double plastic,
    required double paper,
    required double metal,
    required double glass,
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
      double currentPoints = data['points'] ?? 0;
      double currentPlastic = data['plastic'] ?? 0;
      double currentPaper = data['paper'] ?? 0;
      double currentMetal = data['metal'] ?? 0;
      double currentGlass = data['glass'] ?? 0;

      // Novos valores após reciclagem
      double newPlastic = currentPlastic + plastic;
      double newPaper = currentPaper + paper;
      double newMetal = currentMetal + metal;
      double newGlass = currentGlass + glass;

      // Calcula pontos ganhos com base nas quantidades recicladas
      double pointsEarned = (plastic * 5) + (paper * 3) + (metal * 7) + (glass * 4);
      double newPoints = currentPoints + pointsEarned;

      // Atualiza o documento no Firestore
      await userDoc.update({
        'plastic': newPlastic,
        'paper': newPaper,
        'metal': newMetal,
        'glass': newGlass,
        'points': newPoints,
      });

      // Adiciona entrada no histórico do usuário
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .add({
        'type': 'recycle',
        'points': pointsEarned,
        'details': {
          'plastic': plastic,
          'paper': paper,
          'metal': metal,
          'glass': glass,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Sucesso
    } catch (e) {
      return "Erro ao atualizar reciclagem: ${e.toString()}";
    }
  }

  /// Adiciona uma entrada no histórico do usuário.
  Future<void> addHistoryEntry({
    required String type, // 'redeem' | 'recycle' | 'other'
    required int points,
    Map<String, dynamic>? details,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'type': type,
      'points': points,
      'details': details ?? {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Retorna um stream do histórico do usuário ordenado por data (mais recente primeiro).
  Stream<QuerySnapshot<Map<String, dynamic>>> streamHistory() {
    String uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

/// Realiza o resgate de uma recompensa deduzindo os pontos do usuário.
  /// Verifica se há saldo suficiente antes de processar.
  Future<String?> resgatarRecompensa({
    required int pontosNecessarios,
    required String tituloRecompensa,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference userDoc = _firestore.collection('users').doc(uid);

      // Busca os dados atuais do usuário
      DocumentSnapshot doc = await userDoc.get();
      if (!doc.exists) {
        return "Usuário não encontrado.";
      }
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Verifica os pontos atuais
      double currentPoints = data['points'] ?? 0;

      // Valida se o usuário tem pontos suficientes
      if (currentPoints < pontosNecessarios) {
        return "Pontos insuficientes. Faltam ${pontosNecessarios - currentPoints} pontos para este resgate.";
      }

      // Deduz os pontos
      double newPoints = currentPoints - pontosNecessarios;

      // Atualiza o saldo de pontos no Firestore
      await userDoc.update({
        'points': newPoints,
      });

      // Opcional: Adiciona o registro do resgate no histórico
      await addHistoryEntry(
        type: 'redeem',
        points: -pontosNecessarios, // Fica negativo para indicar gasto
        details: {'reward': tituloRecompensa},
      );

      return null; // Retorna null indicando Sucesso
    } catch (e) {
      return "Erro ao processar resgate: ${e.toString()}";
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

  /// Retorna o usuário atual autenticado.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

