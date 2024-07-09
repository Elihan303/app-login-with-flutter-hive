import 'package:flutter/material.dart';

import 'package:flutter_application_1/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Box<User> boxUser;
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  boxUser = await Hive.openBox<User>('userBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _loginMessage = '';

  _login() {
    final email = _emailController.text;
    final name = _nameController.text;
    final user = boxUser.values.firstWhere(
      (user) => user.email == email && user.name == name,
      orElse: () => User(email: '', name: ''),
    );

    if (user.email.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: user)),
      );
    } else {
      setState(() {
        _loginMessage = 'Usuario o contraseña invalido';
      });
    }
  }

  _register() {
    final email = _emailController.text;
    final name = _nameController.text;
    boxUser.add(User(email: email, name: name));
    setState(() {
      _loginMessage = 'Usuario registrado exitosamente';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Inicia sesion'),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrate'),
            ),
            SizedBox(height: 20),
            Text(_loginMessage),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _savedName = '';
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() {
    if (boxUser.isNotEmpty) {
      User user = boxUser.getAt(0)!;
      setState(() {
        _savedName = user.name;
      });
    }
  }

  _clearData() async {
    await boxUser.clear();
    setState(() {
      _savedName = '';
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina de inicio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('Saludos: $_savedName'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearData,
              child: Text('Borrar Datos'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
