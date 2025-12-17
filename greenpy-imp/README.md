
# 🛠️ Instruções de Compilação – Greenpy

Este documento descreve exclusivamente como configurar o ambiente e compilar/executar o aplicativo Greenpy.


## ✅ Pré-requisitos

Antes de iniciar, certifique-se de que você possui:
 * Flutter SDK instalado (versão 3.x ou superior)
 * Dart SDK (incluso no Flutter)
 * Google Chrome (para execução web) ou Android Studio com emulador configurado
 * Conta Google para acesso ao Firebase Console

> Verifique a instalação do Flutter executando o comando abaixo no terminal:
> flutter doctor


## 🔥 Configuração do Firebase

1️⃣ Criar projeto no Firebase
 * Acesse: console.firebase.google.com
 * Clique em Adicionar projeto.
 * Defina o nome do projeto (ex: greenpy).
 * Conclua a criação.
   
2️⃣ Ativar autenticação por Email/Senha
 * Dentro do projeto Firebase, vá em Authentication.
 * Clique em Começar.
 * Ative o método Email/Senha.
 * Crie pelo menos um usuário para testes manuais.
   
3️⃣ Configurar Firebase no Flutter
No diretório raiz do projeto Flutter, execute:
flutterfire configure

 * Selecione o projeto Firebase criado.
 * Esse comando irá gerar automaticamente o arquivo: lib/firebase_options.dart.

## 📦 Instalação das Dependências

Dentro da pasta do projeto, execute o comando para baixar todas as dependências necessárias (incluindo pacotes do Firebase):
flutter pub get

## 🚀 Compilação e Execução

Executar o aplicativo
Para iniciar o app, utilize o comando:
flutter run

Ao ser solicitado, escolha o dispositivo de destino:
 * Chrome: Recomendado para testes rápidos.
 * Android Emulator: Ou dispositivo físico (opcional).
   
## ✅ Teste de Funcionamento

Para validar se a configuração foi bem-sucedida, siga estes passos:
 * O aplicativo iniciará na Tela de Login.
 * Informe o e-mail e senha cadastrados previamente no Firebase.
 * Se os dados estiverem corretos, o app navegará automaticamente para a Tela 
