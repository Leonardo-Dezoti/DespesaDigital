import 'package:despesa_digital/controller/signin_controller.dart';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:despesa_digital/view/authentication_page.dart';
import 'package:despesa_digital/view/registration_page.dart';
import 'package:despesa_digital/view/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/user_db.dart';
import 'model/user.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Inicializa o Firebase
  Get.put(SigninController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Future<int?> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');  // Pode retornar null se o user_id não existir
  }

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTimeUser') ?? true;
  }

  Future<bool> _isUserRegistered(int userId) async {
    UserDB userDB = UserDB();
    User? user = await userDB.fetchUserById(userId);
    return user != null;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: Future.wait([
        _isFirstTime(),
        _loadUserId().then((userId) => _isUserRegistered(userId ?? 0)), // Garante que o `userId` seja passado corretamente
      ]),
      builder: (context, AsyncSnapshot<List<bool>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          bool isFirstTime = snapshot.data![0];
          bool isUserRegistered = snapshot.data![1];
          WidgetsBinding.instance.addPostFrameCallback((_) => Sizes.init(context));
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Minha App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            locale: Locale('pt', 'BR'), // Define o local padrão para português do Brasil
            supportedLocales: [
              const Locale('pt', 'BR'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AuthenticationPage(), // Definindo a tela inicial como a de autenticação,
          );
        }
      },
    );
  }
}

