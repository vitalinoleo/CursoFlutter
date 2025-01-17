import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class BancoDadosCrud {
  // Atributos
  static const String DB_NOME = 'LeoVitalino'; // Nome do banco de dados
  static const String TABLE_NOME = 'Registro'; // Nome da tabela
  static const String
      CREATE_CONTACTS_TABLE_SCRIPT = // Script SQL para criar a tabela
      "CREATE TABLE IF NOT EXISTS contacts(id INTEGER PRIMARY KEY," +
          "nome TEXT, email TEXT, telefone TEXT," +
          "endereco TEXT)";
  
  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), DB_NOME), // Caminho do banco de dados
      onCreate: (db, version) {
        return db.execute(
            CREATE_CONTACTS_TABLE_SCRIPT); // Executa o script de criação da tabela quando o banco é criado
      },
      version: 1,
    );
  }

  // Método para criar um novo contato no banco de dados
  Future<void> create(ContatoModel model) async {
    try {
      final Database db = await _getDatabase();
      await db.insert(
          TABLE_NOME, model.toMap()); // Insere o contato no banco de dados
    } catch (ex) {
      print(ex);
      return;
    }
  }

  // Método para obter todos os contatos do banco de dados
  Future<List<ContatoModel>> getContacts() async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps =
          await db.query(TABLE_NOME); // Consulta todos os contatos na tabela

      return List.generate(
        maps.length,
        (i) {
          return ContatoModel.fromMap(maps[
              i]); // Converte os resultados da consulta para objetos ContactModel
        },
      );
    } catch (ex) {
      print(ex);
      return [];
    }
  }
}