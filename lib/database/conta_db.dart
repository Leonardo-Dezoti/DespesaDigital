import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../model/conta.dart';
import 'database_service.dart';

class ContaDB {

  final tableName = 'conta';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL, 
    "titulo" TEXT NOT NULL,
    "valor" REAL NOT NULL,
    PRIMARY KEY ("id" autoincrement)
    );""");
  }

  void create({required String titulo, required double valor}) async {
    final database = await DatabaseService().database;
    await database.rawInsert(
      '''INSERT INTO $tableName (titulo, valor) VALUES (?, ?)''',
      [titulo, valor],
    );
  }

  Future<List<Conta>> fetchAll() async {
    final database = await DatabaseService().database;
    final contas = await database.rawQuery(
        '''Select * from $tableName ''');
    return contas.map((conta) => Conta.fromSqfliteDatabase(conta)).toList();
  }

  Future<Conta> fetchById(int id) async {
    final database = await DatabaseService().database;
    final contas = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Conta.fromSqfliteDatabase(contas.first);
  }

  void update({required int id, String? titulo, double? valor}) async {
    final database = await DatabaseService().database;
     await database.update(
      tableName,
      {
        if (titulo != null) 'titulo': titulo,

        'valor': valor,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  void delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ? ''', [id]);
  }

  Future<bool> isPaymentMadeThisMonth(int contaId) async {
    final database = await DatabaseService().database;

    // Obtém o primeiro e o último dia do mês atual
    DateTime now = DateTime.now();
    String firstDayOfMonth = DateFormat('yyyy-MM-01').format(now);
    String lastDayOfMonth = DateFormat('yyyy-MM-${DateTime(now.year, now.month + 1, 0).day}').format(now);

    // Consulta para verificar se há um pagamento neste mês para a conta específica
    List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT * FROM movimentacoes
      WHERE conta_id = ? AND tipo = ? AND data BETWEEN ? AND ?
    ''', [contaId, 3, firstDayOfMonth, lastDayOfMonth]);

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>> getPaymentDetails(int id) async {
    final database = await DatabaseService().database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final result = await database.rawQuery(
      '''SELECT data FROM movimentacoes WHERE conta_id = ? AND data >= ? AND data <= ? ORDER BY data DESC LIMIT 1''',
      [id, firstDayOfMonth.toIso8601String(), lastDayOfMonth.toIso8601String()],
    );

    if (result.isNotEmpty) {
      return {
        'paymentMade': true,
        'paymentDate': DateTime.parse(result.first['data'] as String),
      };
    } else {
      return {
        'paymentMade': false,
        'paymentDate': null,
      };
    }
  }

}