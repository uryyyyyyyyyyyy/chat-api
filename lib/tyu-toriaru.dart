import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akebi2/navigator.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _formKey = GlobalKey<FormState>();

  String _sei = '';
  String _mei = '';
  String _height = '';
  String _bloodType = 'A';
  String _life = '実家';
  String? _birthday;
  String? _characterReaction;

  final List<String> bloodTypes = ['A', 'B', 'O', 'AB'];
  final List<String> lifeOptions = ['実家', '寮'];

  final Map<String, String> characterReactions = {
    '小路': '私と同じだ！！',
    '透子': '我ら透子シスターズ！！',
    '実': '...生き物は好きですか？',
    '根子': 'zzz（夢の中で挨拶している）',
    '江利花': 'あら、同じなんて奇遇ね',
    '智乃': 'あっ、えっと...よろしくね！',
    '璃央奈': 'めちゃ偶然！よろしくね！',
    '逢': 'へえ、いい名前してるじゃない。よろしく',
    '景': '同じだ...ちょっと嬉しい...',
    '鮎美': 'わぁとおんなじだ。けやぐなってくれなが。',
    '舞衣': 'うん、よろしく。',
    '靖子': 'なんか運命感じちゃわない？仲良くしよ〜！',
    'りり': '珍しい名前やなぁ。よろ〜。',
    '蛍': '仲良くしよーね。',
    '生静': '生静って私以外にもいるんだ...',
    '瞳': '...よろしく。',
    'ユワ': 'お母さんと同じだ...!',
    'サト': 'お父さんとおんなじ！',
    '花緒': 'ねえねえ、花緒と一緒に遊ばない？',
    '帆呼': '僕は僕。君は君だ。',
    'アンリ': 'アンリ...!いえ、なんでもないわ。',
    '空木': '（なんか言えなんか言えなんか家なんかいい家）...四友団に興味は？',
    '頼': '３組の担任です。',
  };

  void _completeTutorial() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_completed', true);
      await prefs.setString('user_sei', _sei);
      await prefs.setString('user_mei', _mei);
      await prefs.setString('user_height', _height);
      await prefs.setString('user_blood', _bloodType);
      await prefs.setString('user_life', _life);
      await prefs.setString('user_birthday', _birthday ?? ''); // ← 保存

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigator()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ユーザー登録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'あなたは蝋梅学園1年1組の生徒です。プロフィールを入力してください。',
                style: TextStyle(fontSize: 18),
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '姓'),
                onSaved: (value) => _sei = value ?? '',
                validator: (value) => value == null || value.isEmpty ? '姓を入力してください' : null,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '名'),
                onChanged: (value) {
                  setState(() {
                    _mei = value;
                    _characterReaction = characterReactions[_mei];
                  });
                },
                onSaved: (value) => _mei = value ?? '',
                validator: (value) => value == null || value.isEmpty ? '名を入力してください' : null,
              ),

              if (_characterReaction != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Text(
                    _characterReaction!,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),

              // 🔽 誕生日（DatePicker）
              ListTile(
                title: Text('誕生日'),
                subtitle: Text(_birthday ?? '未選択'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2006, 4, 1),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthday =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),

              TextFormField(
                decoration: InputDecoration(labelText: '身長（cm）'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _height = value ?? '',
              ),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '血液型'),
                value: _bloodType,
                items: bloodTypes
                    .map((bt) => DropdownMenuItem(value: bt, child: Text(bt)))
                    .toList(),
                onChanged: (value) => setState(() => _bloodType = value!),
              ),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '住む場所'),
                value: _life,
                items: lifeOptions
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (value) => setState(() => _life = value!),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _completeTutorial,
                child: Text('登録してはじめる'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}