import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:akebi2/screens/login_screen.dart'; // LoginScreenのファイルをインポート
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;



class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  Future<void> register(BuildContext context) async {
    final url = Uri.parse(
      kIsWeb
          ? 'https://chat-api-cf76.onrender.com/register'
          : Platform.isAndroid
          ? 'https://chat-api-cf76.onrender.com/register'
          : 'https://chat-api-cf76.onrender.com/register',
    );


    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
        'username': usernameController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登録成功！ログインしてね')),
      );

        // 少し待ってから遷移（SnackBarを見せるため）
        await Future.delayed(Duration(seconds: 1));

        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),

      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登録失敗')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('新規登録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: InputDecoration(labelText: 'ユーザー名')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'メールアドレス')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'パスワード'), obscureText: true),
            ElevatedButton(
              onPressed: () => register(context),
              child: Text('登録'),
            ),
            // 👇これが追加ボタン
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('ログインはこちら'),
            ),
          ],
        ),
      ),
    );
  }
}