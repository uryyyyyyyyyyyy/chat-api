import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:async';
import 'package:akebi2/delay.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  ChatScreen({required this.chatId, required this.chatName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? sceneData;
  bool isLoading = false;
  bool _showOptions = false;
  List<String> _options = [];
  DateTime? _lastUserMessageTime;
  Timer? _noReplyTimer;

  @override
  void initState() {
    super.initState();
    _loadScene('scene_001');
  }

  //返答時間によるキャラの返答ロジック
  Future<void> _loadScene(String sceneId, {DateTime? replyTime}) async {
    final doc = await FirebaseFirestore.instance.collection('scenes').doc(sceneId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final now = replyTime ?? DateTime.now();
    final hour = now.hour;

    final sentTimeLabel = _lastUserMessageTime != null ? classifyTime(_lastUserMessageTime!) : '';  //最後にユーザーが送った時間
    final readTimeLabel = classifyTime(now);                                                        //キャラが読んだ時間

    //デフォorリプレイ
    String replyText = data['default_reply'] ?? '...';
    final replies = data['replies'] as List<dynamic>? ?? [];

    //sentとreadの一致を調べる
    for (var r in replies) {
      final cond = r['condition'];
      if (cond['sent_time'] == sentTimeLabel && cond['read_time'] == readTimeLabel) {
        replyText = r['text'];
        break;
      }
    }

    setState(() {
      sceneData = data;
      _messages.add({
        'text': replyText,
        'sender': 'ai',
        'timestamp': now,
        'read': true,
      });
      _options = List<String>.from((data['options'] ?? []).map((e) => e['text']));  //選択肢をセット
    });


    // --- 無反応時リアクション処理 ---
    if (data['no_reply_reaction_enabled'] == true) {
      _noReplyTimer?.cancel();  //タイマーストップ
      int delaySeconds = data['no_reply_delay'] ?? 30;
      _noReplyTimer = Timer(Duration(seconds: delaySeconds), () {

        //キャラのリアクション
        final reactionText = data['no_reply_reaction_text'] ?? '...';
        setState(() {
          _messages.add({
            'text': reactionText,
            'sender': 'ai',
            'timestamp': DateTime.now(),
            'read': true,
          });
        });
      });
    }
  }

  //ユーザーがメッセージを送信した時の処理
  void _sendMessage(String text) {
    _noReplyTimer?.cancel();

    //optionsから一致するものを探す
    final selectedOption = (sceneData?['options'] as List?)?.firstWhere(
          (e) => e['text'] == text,
      orElse: () => null,
    );
    if (selectedOption == null) return;

    final now = DateTime.now();
    _lastUserMessageTime = now;  //前回メッセージ記録として保存

    final behavior = getReplyBehavior();  //既読遅延

    final userMessage = {
      'text': text,
      'sender': 'user',
      'timestamp': now,
      'read': false,
    };

    setState(() {
      _messages.add(userMessage);
      _controller.clear();
      _showOptions = false;
    });

    //既読遅延後に既読をつける
    if (behavior['canReply'] == true) {
      Future.delayed(Duration(seconds: behavior['delay']), () {
        setState(() {
          for (int i = _messages.length - 1; i >= 0; i--) {
            if (_messages[i]['sender'] == 'user' && !_messages[i]['read']) {
              _messages[i]['read'] = true;
              break;
            }
          }
        });

        //次のシーンへ
        final replyTime = DateTime.now();
        final nextSceneId = selectedOption['next'];
        _loadScene(nextSceneId, replyTime: replyTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                final time = message['timestamp'] as DateTime;
                final formattedTime = DateFormat('HH:mm').format(time);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,

                    //ユーザーのメッセージの並び
                    children: isUser
                        ? [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (message['read'] == true)
                            Text('既読', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/user_icon.png'),
                      ),
                    ]

                    //キャラのメッセージの並び
                        : [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/ashita_icon.png'),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),


          //テキストボックス下
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //入力欄と送信ボタン
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _showOptions = !_showOptions);
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _controller,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: '選択肢を選んでください',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        final text = _controller.text;
                        if (text.isNotEmpty) {
                          _sendMessage(text);
                        }
                      },
                    ),
                  ],
                ),
                if (_showOptions)
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: _options.map((text) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _controller.text = text;
                                  _showOptions = false;
                                });
                              },
                              child: Text(text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
