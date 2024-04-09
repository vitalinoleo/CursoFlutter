import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

// Classe que representa um usuário ID
class User {
  final int id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});

  // Converte um objeto User em um mapa
  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password};
  }
}

// Classe responsável pela interação com o banco de dados SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  // Retorna uma instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // Cria a tabela de usuários
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
        'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)');
  }

  // Insere um novo usuário no banco de dados
  Future<int> insert(user) async {
    Database db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // Obtém um usuário do banco de dados com base no nome de usuário e senha
  Future<User?> getUser(String username, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password]);
    if (maps.length > 0) {
      return User(
        id: maps[0]['id'],
        username: maps[0]['username'],
        password: maps[0]['password'],
      );
    }
    return null;
  }
}

// Classe principal do aplicativo
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App with SQLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegisterScreen(), // Tela de registro como tela inicial
    );
  }
}

// Tela de registro de usuário
class RegisterScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar'), // Título da tela
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'), // Campo de entrada para nome de usuário
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'), // Campo de entrada para senha
              obscureText: true, // Mascara o texto para senha
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text.trim();
                String password = _passwordController.text.trim();

                if (username.isNotEmpty && password.isNotEmpty) {
                  await DatabaseHelper.instance
                      .insert(User(id:1, username: username, password: password)); // Insere usuário no banco de dados
                  _usernameController.clear();
                  _passwordController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User registered successfully')), // Mostra mensagem de sucesso
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')), // Mostra mensagem de erro
                  );
                }
              },
              child: Text('Register'), // Botão para registrar
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de login do usuário
class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'), // Título da tela
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'), // Campo de entrada para nome de usuário
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'), // Campo de entrada para senha
              obscureText: true, // Mascara o texto para senha
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text.trim();
                String password = _passwordController.text.trim();

                if (username.isNotEmpty && password.isNotEmpty) {
                  User? user = await DatabaseHelper.instance.getUser(username, password); // Obtém usuário do banco de dados
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login bem sucedido')), // Mostra mensagem de login bem-sucedido
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login ou Senha estão incorretos')), // Mostra mensagem de erro de login
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')), // Mostra mensagem de erro se campos não preenchidos
                  );
                }
              },
              child: Text('Login'), // Botão para fazer login
            ),
          ],
        ),
      ),
    );
  }
}
