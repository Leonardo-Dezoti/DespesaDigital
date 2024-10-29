import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      // Inicia o processo de login
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Login cancelado pelo usuário.');
        return;
      }

      // Obtenha as credenciais do usuário Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Login bem-sucedido. Nome: ${googleUser.displayName}, Email: ${googleUser.email}');

      // Aqui você pode salvar as credenciais do Google no SQLite, Firebase, etc.

    } on Exception catch (e, stacktrace) {
      print('Erro ao fazer login com Google: $e');
      print('Stacktrace: $stacktrace');

    } on PlatformException catch (e) {
      print('Erro de plataforma ao fazer login com Google: ${e.message}');
      print('Detalhes adicionais: ${e.details}');
    }
  }
}
