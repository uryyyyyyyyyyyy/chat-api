import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akebi2/firebase_options.dart';
import 'screens/login_screen.dart';//ログイン画面
import 'screens/RegisterScreen.dart';//新規登録画面
import 'package:shared_preferences/shared_preferences.dart';//ログイン保持
import 'navigator.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  print('Firebase initializeApp 呼び出し前');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('runApp呼び出し前');
    runApp(MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn ? MainNavigator() : LoginScreen(),
    ));
  } catch (e, st) {
    print('Firebase初期化エラー: $e');
    print('StackTrace: $st');
  }
}


// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//
//   void _sendMessage() {
//     if (_controller.text.isNotEmpty) {
//       final userMessage = {
//         'text': _controller.text,
//         'sender': 'user',
//         'timestamp': DateTime.now(),
//         'read': false,
//       };
//
//       setState(() => _messages.add(userMessage));
//       _controller.clear();
//
//       final behavior = getReplyBehavior();
//       if (behavior['canReply'] == true) {
//         final delayDuration = Duration(seconds: behavior['delay']);
//         final extraDelay = Duration(seconds: Random().nextInt(10) + 3);
//         final totalDelay = delayDuration + extraDelay;
//
//         Future.delayed(totalDelay, () async {
//           setState(() {
//             for (int i = _messages.length - 1; i >= 0; i--) {
//               if (_messages[i]['sender'] == 'user' && _messages[i]['read'] == false) {
//                 _messages[i]['read'] = true;
//               }
//             }
//           });
//
//           print("AI呼び出し開始: ${userMessage['text']}");
//           await fetchAIReplyViaHttp(userMessage['text'] as String, (replyMessage) {
//             setState(() => _messages.add(replyMessage));
//           });
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('チャット')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 bool isUser = message['sender'] == 'user';
//                 DateTime time = message['timestamp'];
//                 String formattedTime = DateFormat('HH:mm').format(time);
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                   child: Row(
//                     mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       if (!isUser) ...[
//                         CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/ashita_icon.png')),
//                         SizedBox(width: 5),
//                       ],
//                       if (isUser)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(message['read'] == true ? '既読' : '', style: TextStyle(fontSize: 10, color: Colors.grey)),
//                             Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey)),
//                           ],
//                         ),
//                       if (isUser) SizedBox(width: 5),
//                       Stack(
//                         clipBehavior: Clip.none,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                             decoration: BoxDecoration(
//                               color: isUser ? Colors.greenAccent : Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
//                               ],
//                             ),
//                             constraints: BoxConstraints(
//                               maxWidth: MediaQuery.of(context).size.width * 0.7,
//                             ),
//                             child: Text(
//                               message['text'] ?? '（メッセージなし）',
//                               style: TextStyle(color: isUser ? Colors.white : Colors.black),
//                             ),
//                           ),
//                           Positioned(
//                             top: 12,
//                             right: isUser ? -6 : null,
//                             left: isUser ? null : -6,
//                             child: CustomPaint(
//                               size: Size(20, 20),
//                               painter: BubbleTailPainter(
//                                 isUser: isUser,
//                                 color: isUser ? Colors.greenAccent : Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (!isUser)
//                         SizedBox(width: 5),
//                       if (!isUser)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey)),
//                           ],
//                         ),
//                       if (isUser)
//                         SizedBox(width: 5),
//                       if (isUser)
//                         CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/user_icon.png')),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'メッセージを入力...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class BubbleTailPainter extends CustomPainter {
//   final bool isUser;
//   final Color color;
//
//   BubbleTailPainter({required this.isUser, required this.color});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;
//
//     Path path = Path();
//     if (isUser) {
//       path.moveTo(0, 0);
//       path.quadraticBezierTo(12, 6, 0, 12);
//     } else {
//       path.moveTo(12, 0);
//       path.quadraticBezierTo(0, 6, 12, 12);
//     }
//     path.close();
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }