import 'package:flutter/material.dart';
import '../controller/auth_service.dart';
import '../controller/main_navigator.dart';
import 'authentication_page.dart';

class GoogleInsertPasswordPage extends StatefulWidget {
  final String email;
  final String username; // Adicionando o nome do usuário
  final String? profilePictureUrl; // Adicionando a URL da foto de perfil

  GoogleInsertPasswordPage({
    required this.email,
    required this.username,
    this.profilePictureUrl,
  });

  @override
  _GoogleInsertPasswordPageState createState() => _GoogleInsertPasswordPageState();
}

class _GoogleInsertPasswordPageState extends State<GoogleInsertPasswordPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  int _attemptCount = 0; // Contador de tentativas

  Future<void> _verifyPassword() async {
    String password = _passwordController.text;

    bool isPasswordCorrect = await _authService.verifyPassword(widget.email, password);

    if (isPasswordCorrect) {
      // Se a senha estiver correta, redirecionar para a tela principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainNavigator()),
      );
    } else {
      setState(() {
        _attemptCount++; // Incrementar o contador de tentativas
      });

      if (_attemptCount >= 3) {
        // Se as tentativas atingirem 3, deslogar o usuário e redirecionar para a tela de login principal
        await _authService.signOutGoogle();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AuthenticationPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você excedeu o limite de tentativas. Faça login novamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Senha incorreta. Você tem ${3 - _attemptCount} tentativas restantes.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraindo o primeiro nome do username
    String firstName = widget.username.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inserir Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Saudação personalizada
            Text(
              'Olá, $firstName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Foto de perfil do usuário centralizada
            if (widget.profilePictureUrl != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.profilePictureUrl!),
              ),
            if (widget.profilePictureUrl == null)
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/user_avatar.png'),
              ),
            SizedBox(height: 32),

            // Texto de instrução
            Text(
              'Insira sua senha para logar no app',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),

            // Campo para inserir a senha
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 24),

            // Botão para verificar a senha
            ElevatedButton(
              onPressed: _verifyPassword,
              child: Text('Verificar Senha'),
            ),
          ],
        ),
      ),
    );
  }
}
