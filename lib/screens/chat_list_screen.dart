import 'package:flutter/material.dart';
import 'chat_screen.dart'; // チャット画面を読み込む

class ChatListScreen extends StatelessWidget {
  // 仮のチャットデータ
  final List<Map<String, String>> chats = [
    {
      'id': 'chat1',
      'name': '明日小路',
      'icon': 'assets/ashita_icon.png',
    },
    {
      'id': 'chat2',
      'name': '風紀委員長',
      'icon': 'assets/ashita_icon.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('チャット一覧')),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];

          //トークページを並べる
          return ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(chat['icon']!),),
            title: Text(chat['name']!),

            //ChatScreenに遷移し、IDを渡す
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chat['id']!,
                    chatName: chat['name']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
