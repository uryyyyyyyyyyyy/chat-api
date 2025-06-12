import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chat_list_screen.dart';//チャット一覧
import 'screens/chat_screen.dart';//チャット画面

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ChatListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //表示切り替え
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'), //家のアイコン
          BottomNavigationBarItem( //チャットのアイコン、未読表示付き
            icon: Stack(
              children: [
                Icon(Icons.chat),
                Positioned(  //右上に配置
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '3', // 未読数（仮）
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'チャット',
          ),
        ],
      ),
    );
  }
}