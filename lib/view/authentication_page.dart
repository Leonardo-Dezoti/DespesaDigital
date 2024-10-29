import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importando Google Sign-In
import '../controller/auth_service.dart';
import '../controller/main_navigator.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'google_auth.dart';
import 'google_password.dart';
import 'registration_page.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final AuthService _authService = AuthService(); // Instanciando o AuthService
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Login com Google
  Future<void> _loginWithGoogle() async {
    try {
      final UserCredential? userCredential = await _authService.signInWithGoogle();
      final user = userCredential?.user;

      if (user != null) {
        String email = user.email ?? 'Sem email';
        String username = user.displayName ?? 'Sem Nome';

        // Verificar se o usuário já está no banco de dados
        bool userExists = await _authService.userExists(email);

        if (!userExists) {
          // Se o usuário não existir, registra o usuário com senha null
          await _authService.registerNewGoogleUser(
            email: email,
            username: username,
            googleId: user.uid,
            profilePictureUrl: user.photoURL,
          );

          // Após registrar o usuário, levar à tela de criação de senha
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GoogleCreatePasswordPage(email: email, username: username),
            ),
          );
        } else {
          // Se o usuário já existir, verificar se ele tem senha
          bool hasPassword = await _authService.hasPassword(email);

          if (!hasPassword) {
            // Leva para a tela de criação de senha se o usuário não tiver uma senha
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GoogleCreatePasswordPage(email: email, username: username),
              ),
            );
          } else {
            // Se o usuário já tiver senha, levar para a tela de inserção de senha
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GoogleInsertPasswordPage(email: email, username: username, profilePictureUrl: user.photoURL),
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar login com Google: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco para toda a página
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: [
                              // Cabeçalho
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 60.0),
                                child: Center(
                                  child: Text(
                                    'Autenticação',
                                    style: AppTextStyles.mediumText.apply(color: AppColors.purpledarkOne),
                                  ),
                                ),
                              ),

                              // Campo de email
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16), // Espaço entre os campos

                              // Campo de senha
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true, // Ocultar o texto da senha
                              ),
                              SizedBox(height: 24),

                              // Botão para login com email e senha
                              ElevatedButton(
                                onPressed: () async {
                                  String email = _emailController.text;
                                  String password = _passwordController.text;

                                  bool success = await _authService.signInWithEmailAndPassword(email, password);

                                  if (success) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => MainNavigator()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Falha na autenticação. Verifique suas credenciais.')),
                                    );
                                  }
                                },
                                child: Text('Entrar'),
                              ),
                              SizedBox(height: 24),

                              // Botão personalizado de login com o Google
                              SignInButton(
                                Buttons.Google,
                                text: "Logar com o Google",
                                onPressed: _loginWithGoogle,
                              ),
                              SizedBox(height: 16), // Espaço entre os botões

                              // Mensagem para primeiro login com o Google
                              Text(
                                'Não tem uma conta? Faça o primeiro login utilizando o botão do Google acima',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          // Logo sempre fixado na parte inferior
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Image.asset('assets/images/logo1.png', width: 150, height: 150),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
