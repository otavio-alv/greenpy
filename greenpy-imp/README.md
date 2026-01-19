
# Instruções de Compilação Greenpy

## ✅ Pré-requisitos

Antes de iniciar, certifique que possui instalado:
 * Flutter SDK instalado (versão 3.x ou superior)
 * Dart SDK (incluso no Flutter)
 * Google Chrome (para execução web) ou Android Studio com emulador configurado
 * Conta Google para acesso ao Firebase Console

> Verifique a instalação do Flutter executando o comando abaixo no terminal:
> flutter doctor

## Instalação das Dependências

Dentro da pasta do projeto, execute o comando para baixar todas as dependências necessárias (incluindo pacotes do Firebase):
flutter pub get

## Compilação e Execução

Executar o aplicativo
Para iniciar o app, utilize o comando:
flutter run

Ao ser solicitado, escolha o dispositivo de destino:
 * Chrome: Recomendado para teste.
 * Android Emulator: Para visualização real da aplicação.
   
## Teste de Funcionamento

Para validar se a configuração foi bem-sucedida, siga estes passos:
 * O aplicativo iniciará na Tela de Login.
 * Cadastre ou realize login com usuário já cadastrado.
 * Se os dados estiverem corretos, o app navegará automaticamente para a Tela Inicial!
