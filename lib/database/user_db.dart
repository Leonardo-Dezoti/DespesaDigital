import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart'; // Para hash de senha
import '../model/user.dart';
import 'database_service.dart';

class UserDB {
  final tableName = 'users';

  // Atualizando a criação da tabela para incluir google_id e profile_picture_url
  Future<void> createUser(Database database) async {
    await database.execute('''
    CREATE TABLE IF NOT EXISTS $tableName (
      "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "username" TEXT NOT NULL,
      "email" TEXT NOT NULL UNIQUE,
      "auth_method" TEXT NOT NULL,
      "pin" TEXT,
      "password" TEXT,
      "google_id" TEXT,                     -- Novo campo para o ID do Google
      "profile_picture_url" TEXT            -- Novo campo para a URL da foto de perfil
    );
    ''');
  }

  // Cria um usuário
  Future<int> create({
    required String username,
    required String email,
    required String authMethod,
    String? pin,
    String? password,
    String? googleId,
    String? profilePictureUrl,
  }) async {
    final database = await DatabaseService().database;

    // Inserir o usuário no banco de dados
    return await database.insert(
      tableName,
      {
        'username': username,
        'email': email,
        'auth_method': authMethod,
        'pin': pin,
        'password': password != null ? hashPassword(password) : null, // Hash da senha se presente
        'google_id': googleId,
        'profile_picture_url': profilePictureUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  // Busca usuário pelo email
  Future<User?> fetchUserByEmail(String email) async {
    final database = await DatabaseService().database;
    final result = await database.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return User.fromSqfliteDatabase(result.first);
    }
    return null;
  }

  // Busca usuário pelo ID
  Future<User?> fetchUserById(int id) async {
    final database = await DatabaseService().database;
    final result = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return User.fromSqfliteDatabase(result.first);
    }
    return null;
  }

  // Função para atualizar a senha de um usuário pelo email
  Future<int> updatePassword(String email, String newPassword) async {
    final database = await DatabaseService().database;

    return await database.update(
      tableName,
      {'password': newPassword}, // Atualiza a senha
      where: 'email = ?',        // Busca pelo email
      whereArgs: [email],
    );
  }

  // Verifica a senha do usuário
  Future<bool> verifyPassword(String email, String inputPassword) async {
    final user = await fetchUserByEmail(email);
    if (user != null && user.password != null) {
      return BCrypt.checkpw(inputPassword, user.password!);  // Verificar senha hasheada
    }
    return false;
  }

  // Função para hashear a senha
  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}
