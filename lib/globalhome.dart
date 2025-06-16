import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalHomeScreen extends StatefulWidget {
  @override
  _GlobalHomeScreenState createState() => _GlobalHomeScreenState();
}

class _GlobalHomeScreenState extends State<GlobalHomeScreen> {
  String userName = '';
  String birthday = '';
  String life = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final sei = prefs.getString('user_sei') ?? '';
    final mei = prefs.getString('user_mei') ?? '';
    final bday = prefs.getString('user_birthday') ?? '';
    final place = prefs.getString('user_life') ?? '';

    setState(() {
      userName = '$sei $mei';
      birthday = bday;
      life = place;
    });
  }

  void _goToChapter(String chapterId) {
    // チャプターごとの画面に遷移
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChapterHomeScreen(chapterId: chapterId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('蝋梅学園')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ようこそ、$userName さん', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('誕生日: $birthday'),
            Text('住まい: $life'),
            SizedBox(height: 24),

            Text('チャプターを選択してください：', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _goToChapter('chapter_01'),
              child: Text('チャプター1：入学式と最初の出会い'),
            ),
            ElevatedButton(
              onPressed: () => _goToChapter('chapter_02'),
              child: Text('チャプター2：昼休みの事件'),
            ),
            // 追加のチャプターはここに増やせる
          ],
        ),
      ),
    );
  }
}

// 仮のチャプター用Widget（必要に応じて置き換えて）
class ChapterHomeScreen extends StatelessWidget {
  final String chapterId;

  ChapterHomeScreen({required this.chapterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('チャプター: $chapterId')),
      body: Center(child: Text('ここにチャット一覧などを表示')),
    );
  }
}