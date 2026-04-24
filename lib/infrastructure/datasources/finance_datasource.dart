import '../models/finance_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Interface da fonte de dados
abstract class IFinanceDatasource {
  Future<List<ContaModel>> getContaModels();
  Future<void> saveContaModel(ContaModel model);
  Future<void> deleteContaModel(String id);

  Future<List<TransactionModel>> getLancamentoModels();
  Future<void> saveLancamentoModel(TransactionModel model);
  Future<void> deleteLancamentoModel(String id);

  Future<List<MetaModel>> getMetaModels();
  Future<void> saveMetaModel(MetaModel model);
  Future<void> deleteMetaModel(String id);
}

class SqfliteFinanceDatasource implements IFinanceDatasource {
  // Singleton: uma única instância do banco para todo o app
  static Database? _db;

  // Getter: abre o banco só uma vez, reutiliza sempre
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // Abre o arquivo .db no dispositivo
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath(); // pasta correta por SO
    final path = join(dbPath, 'my_finance.db'); // caminho completo do arquivo

    return await openDatabase(
      path,
      version: 1, // incrementar se mudar as tabelas no futuro
      onCreate: _createTables, // chamado só na primeira vez
    );
  }

  // Cria as tabelas — roda só quando o banco é criado pela primeira vez
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contas (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        saldo TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lancamentos (
        id TEXT PRIMARY KEY,
        descricao TEXT NOT NULL,
        valor TEXT NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        contaId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS metas (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        valorAlvo TEXT NOT NULL,
        valorAtual TEXT NOT NULL,
        dataLimite TEXT NOT NULL
      )
    ''');
  }

  // ─── CONTAS ───────────────────────────────────────────────

  @override
  Future<List<ContaModel>> getContaModels() async {
    final db = await database;
    final maps = await db.query('contas'); // SELECT * FROM contas
    return maps.map((m) => ContaModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveContaModel(ContaModel model) async {
    final db = await database;
    await db.insert(
      'contas',
      model.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // INSERT ou UPDATE se já existir
    );
  }

  @override
  Future<void> deleteContaModel(String id) async {
    final db = await database;
    await db.delete(
      'contas',
      where: 'id = ?', // nunca concatene strings SQL
      whereArgs: [id], // o sqflite substitui o ? por este valor com segurança
    );
  }

  // ─── LANÇAMENTOS ──────────────────────────────────────────

  @override
  Future<List<TransactionModel>> getLancamentoModels() async {
    final db = await database;
    final maps = await db.query(
      'lancamentos',
      orderBy:
          'data DESC', // mais recentes primeiro (ISO 8601 é ordenável como texto)
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveLancamentoModel(TransactionModel model) async {
    final db = await database;
    await db.insert(
      'lancamentos',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteLancamentoModel(String id) async {
    final db = await database;
    await db.delete('lancamentos', where: 'id = ?', whereArgs: [id]);
  }

  // ─── METAS ────────────────────────────────────────────────

  @override
  Future<List<MetaModel>> getMetaModels() async {
    final db = await database;
    final maps = await db.query('metas');
    return maps.map((m) => MetaModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveMetaModel(MetaModel model) async {
    final db = await database;
    await db.insert(
      'metas',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteMetaModel(String id) async {
    final db = await database;
    await db.delete('metas', where: 'id = ?', whereArgs: [id]);
  }
}
