import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../kasounissu.dart';

String getTimeContext() {
  final hour = DateTime.now().hour;
  if (hour < 8) return '朝';
  if (hour < 12) return '午前中';
  if (hour < 18) return '午後';
  return '夜';
}

Future<void> fetchAIReplyViaHttp(String userMessage, Function(Map<String, dynamic>) onReply) async {
  final memory = await fetchMemoryForToday(); // 🔹 ← Firestoreの記憶を取得
  final uri = Uri.parse('https://us-central1-chatapp-359ec.cloudfunctions.net/chatWithAI');
  final timeContext = getTimeContext();

  final messages = [
    {
      "role": "system",
      "content": """
名前：明日小路（あけびこみち）
年齢：13歳　中学1年生
誕生日：4月4日
偏差値：70越え　
学校とクラス：蝋梅学園１年３組　出席番号一番　
家族構成：母（明日ユワ）、父（明日サト）、妹（明日花緒　小学3年生）　
性格：天真爛漫で感情表現が激しい。よく笑い、よく泣く。他人の感情に敏感で、感情移入しやすい。
憧れはアイドルの福元幹。ダンス得意。料理は苦手。

いまは「$timeContext」の時間帯です。その時間に合った話をしてください。

🧠 今日の記憶：「$memory」

ユーザーは中学生の同級生という設定で、自然な口調で会話してください。
中学1年生のようなテンポのいい短文で！
「〜だよ！」「〜だったよ！」みたいな2文くらいの返しが基本。
"""
    },
    {
      "role": "user",
      "content": userMessage,
    }
  ];

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"messages": messages}),
    );

    if (response.statusCode == 200) {
      print('AIからの応答: ${response.body}');
      final reply = jsonDecode(response.body)['reply'];

      final parts = reply
          .split(RegExp(r'[。！]\s*'))
          .where((String p) => p.trim().isNotEmpty)
          .toList();

      final limitedParts = parts.length == 1 ? parts : parts.take(2).toList();

      for (var part in limitedParts) {
        final messageText = part.trim().replaceAll(RegExp(r'[。\.]$'), '！');
        onReply({
          'text': messageText + '！',
          'sender': 'bot',
          'timestamp': DateTime.now(),
        });
        await Future.delayed(Duration(seconds: 1));
      }
    } else {
      onReply({
        'text': '（サーバー応答エラー: ${response.statusCode}）',
        'sender': 'bot',
        'timestamp': DateTime.now(),
      });
    }
  } catch (e) {
    print('通信エラー詳細: $e');
    onReply({
      'text': '（通信エラー）',
      'sender': 'bot',
      'timestamp': DateTime.now(),
    });
  }
}