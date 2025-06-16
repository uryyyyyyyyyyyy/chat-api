import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akebi2/navigator.dart';
import 'tyu-toriaru.dart'; // チュートリアル画面
import 'globalhome.dart';

class TitleScreen extends StatelessWidget {
  Future<void> _handleTap(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasDoneTutorial = prefs.getBool('tutorial_completed') ?? false;

    if (hasDoneTutorial) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GlobalHomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TutorialScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150),
              SizedBox(height: 20),
              Text(
                '明日ちゃんのセーラー服',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'タップしてはじめる',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
