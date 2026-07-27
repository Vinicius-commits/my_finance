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

  Future<List<CategoryModel>> getCategoryModels();
  Future<void> saveCategoryModel(CategoryModel model);
  Future<void> deleteCategoryModel(String id);

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
      version: 2,
      onCreate: (db, v) async {
        await _createTables(db, v);
        await _seedDefaultCategories(db);
      },
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE lancamentos ADD COLUMN categoriaId TEXT',
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categorias (
          id TEXT PRIMARY KEY,
          nome TEXT NOT NULL,
          tipo TEXT NOT NULL,
          cor TEXT NOT NULL
        )
      ''');
      await _seedDefaultCategories(db);
    }
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
        contaId TEXT NOT NULL,
        categoriaId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS categorias (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        cor TEXT NOT NULL
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

  Future<void> _seedDefaultCategories(Database db) async {
    const rows = <Map<String, String>>[
      {'id': 'cat_rec_salario', 'nome': 'Salário', 'tipo': 'revenue', 'cor': 'FF66BB6A'},
      {
        'id': 'cat_rec_freelance',
        'nome': 'Freelance / extras',
        'tipo': 'revenue',
        'cor': 'FF42A5F5',
      },
      {'id': 'cat_rec_invest', 'nome': 'Rendimentos', 'tipo': 'revenue', 'cor': 'FF26A69A'},
      {'id': 'cat_rec_outros', 'nome': 'Outras receitas', 'tipo': 'revenue', 'cor': 'FF78909C'},
      {
        'id': 'cat_exp_moradia',
        'nome': 'Moradia / aluguel',
        'tipo': 'expense',
        'cor': 'FFEF5350',
      },
      {
        'id': 'cat_exp_agua_luz',
        'nome': 'Água, luz e gás',
        'tipo': 'expense',
        'cor': 'FFFFCA28',
      },
      {'id': 'cat_exp_transporte', 'nome': 'Transporte', 'tipo': 'expense', 'cor': 'FFAB47BC'},
      {'id': 'cat_exp_alimentacao', 'nome': 'Alimentação', 'tipo': 'expense', 'cor': 'FFFF7043'},
      {'id': 'cat_exp_saude', 'nome': 'Saúde', 'tipo': 'expense', 'cor': 'FFEC407A'},
      {'id': 'cat_exp_educacao', 'nome': 'Educação', 'tipo': 'expense', 'cor': 'FF5C6BC0'},
      {'id': 'cat_exp_lazer', 'nome': 'Lazer', 'tipo': 'expense', 'cor': 'FF29B6F6'},
      {'id': 'cat_exp_outros', 'nome': 'Outras despesas', 'tipo': 'expense', 'cor': 'FF9E9E9E'},
    ];
    for (final r in rows) {
      await db.insert(
        'categorias',
        r,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
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

  // ─── CATEGORIAS ─────────────────────────────────────────────

  @override
  Future<List<CategoryModel>> getCategoryModels() async {
    final db = await database;
    final maps = await db.query(
      'categorias',
      orderBy: 'tipo ASC, nome COLLATE NOCASE ASC',
    );
    return maps.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<void> saveCategoryModel(CategoryModel model) async {
    final db = await database;
    await db.insert(
      'categorias',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCategoryModel(String id) async {
    final db = await database;
    await db.update(
      'lancamentos',
      {'categoriaId': null},
      where: 'categoriaId = ?',
      whereArgs: [id],
    );
    await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
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
