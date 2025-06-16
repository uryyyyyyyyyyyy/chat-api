import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/login_screen.dart';
import '../navigator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _goToLogin();
        return;
      }

      final response = await http.get(
        Uri.parse(
          kIsWeb
            ? 'https://chat-api-cf76.onrender.com/protected'
            : Platform.isAndroid
            ? 'http://10.0.2.2:3000/protected'
            : 'http://localhost:3000/protected',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigator()),
        );
      } else {
        prefs.remove('token');
        _goToLogin();
      }
    } catch (e) {
      print('🔥 エラー発生: $e');
      _goToLogin(); // 安全のためログイン画面へ飛ばす
    }
  }


  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // ローディング画面
    );
  }
}