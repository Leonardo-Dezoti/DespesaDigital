import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/user_db.dart';
import '../model/user.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:despesa_digital/utils/sizes.dart';
import 'authentication_page.dart'; // Import da tela de autenticação
import '../controller/auth_service.dart'; // Import do serviço de autenticação

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<User> _futureUser;
  final AuthService _authService = AuthService(); // Instanciando o AuthService

  @override
  void initState() {
    super.initState();
    _futureUser = _loadUser();
  }

  Future<User> _loadUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId != null) {
        print('ID do usuário encontrado: $userId'); // Log do ID do usuário

        UserDB userDB = UserDB();
        User? user = await userDB.fetchUserById(userId);

        if (user != null) {
          print('Usuário encontrado no banco de dados: ${user.username}'); // Log do usuário
          return user;
        } else {
          print('Usuário não encontrado no banco de dados.');
          throw Exception("Usuário não encontrado no banco de dados");
        }
      } else {
        print('ID de usuário não encontrado no SharedPreferences.');
        throw Exception("ID de usuário não encontrado no SharedPreferences");
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e'); // Log do erro
      throw Exception("Erro ao carregar usuário: $e");
    }
  }

  Future<void> _logout() async {
    // Logout do Google e redirecionamento para a tela de autenticação
    await _authService.signOutGoogle();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthenticationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.purpleGradient,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(500, 30),
                  bottomRight: Radius.elliptical(500, 30),
                ),
              ),
              height: 150.h,
            ),
          ),
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 80.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 150.w, vertical: 32.h),
              decoration: const BoxDecoration(
                color: AppColors.purpledarkOne,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Perfil do Usuário',
                    style: AppTextStyles.mediumText.apply(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 350.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: FutureBuilder<User>(
              future: _futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Erro no FutureBuilder: ${snapshot.error}'); // Log do erro no FutureBuilder
                  return Center(child: Text('Erro ao carregar usuário: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  User user = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: user.profilePictureUrl != null
                                    ? NetworkImage(user.profilePictureUrl!)
                                    : AssetImage('assets/images/user_avatar.png') as ImageProvider,
                              ),
                              SizedBox(height: 16),
                              Text(
                                user.username,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                user.email,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  print('Usuário não encontrado no FutureBuilder.'); // Log para usuário não encontrado
                  return Center(child: Text('Usuário não encontrado'));
                }
              },
            ),
          ),

          // Botão fixo de Logout na parte inferior da tela
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _logout, // Chama o método de logout
                child: Text(
                  'Sair da Conta',
                  style: TextStyle(
                    color: Colors.purple, // Texto roxo
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red, backgroundColor: Colors.white, // Cor da borda quando pressionado
                  side: BorderSide(color: Colors.red, width: 2), // Borda vermelha
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordas arredondadas
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}
