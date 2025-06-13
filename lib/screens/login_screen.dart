import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:akebi2/main.dart';//mainに遷移
import 'package:shared_preferences/shared_preferences.dart';//ログイン保持
import 'package:akebi2/screens/Registerscreen.dart'; // RegisterScreenのファイルをインポート
import '../navigator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;


class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final url = Uri.parse(
      kIsWeb
          ? 'https://chat-api-cf76.onrender.com/login'
          : Platform.isAndroid
          ? 'https://chat-api-cf76.onrender.com/login'
          : 'https://chat-api-cf76.onrender.com/login',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      // ✅ ログイン情報を保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);   //トークン保存
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', result['username']);


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログイン成功！ようこそ ${result['username']}')),
      );

      await Future.delayed(Duration(seconds: 1));

      // ChatScreenに遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigator()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログイン失敗')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text('ログイン'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('新期登録はこちら'),
            ),
          ],
        ),
      ),
    );
  }
}