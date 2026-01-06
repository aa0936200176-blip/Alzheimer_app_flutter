import 'package:flutter/material.dart';

import 'home_page.dart';
import 'home_page_review.dart';
import 'remind_page.dart';
import 'disseminate_page.dart';
import 'evaluate_page.dart';
import 'login_page.dart';
import 'healthedu_page.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Alzheimer's prediction",
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;//底部導航欄

  void _onItemTap(int index) {
    setState(() => _selectedIndex = index);

  }



  final List<String> _titles = [
    '遊戲訓練',
    '每日提醒設定',
    '阿茲海默風險預測',
    '衛教宣導',
    '登入',
  ];// 用來顯示不同頁面的標題


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),// 顯示當前選中的標題
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 18,
        unselectedFontSize: 14,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: '首頁',
            activeIcon: Icon(Icons.home, color: Colors.deepOrange),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_alert_outlined), label: '每日提醒',
            activeIcon: Icon(Icons.add_alert, color: Colors.purple),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility), label: '健康預測',
            activeIcon: Icon(Icons.accessibility, color: Colors.amber),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined), label: '衛教宣導',
            activeIcon: Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined), label: '登入',
            activeIcon: Icon(Icons.account_circle, color: Colors.green),
          ),
        ],
        onTap: _onItemTap,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange, // 選中后的顏色
        unselectedItemColor: Colors.grey, // 未選中的顏色
      ),//底部導航欄

      body: IndexedStack(
        index: _selectedIndex,
        children: [

          Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 10.0),
                child: Row(
                  children: <Widget>[

                    Column(
                      children: [
                        SizedBox(height: 30), //button1和手機的距離

                        ElevatedButton(

                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GameLevelPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // 按鈕顏色
                            //minimumSize: Size(170, 170), // 按鈕尺寸
                            padding: EdgeInsets.zero, // 去除內距，圖片才會貼齊
                            fixedSize: Size(150, 170), // 正方形按鈕
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),//0度是直角
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25), // 確保整個內容也有圓角
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 圖片部分
                                SizedBox(
                                  height: 130,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                    child: Image.asset(
                                      'assets/image/a.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // 文字部分
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '記憶翻牌',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),//button1

                        SizedBox(height: 33),//垂直間距

                        ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PuzzleGamePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // 按鈕顏色
                  //minimumSize: Size(170, 170), // 按鈕尺寸
                  padding: EdgeInsets.zero, // 去除內距，圖片才會貼齊
                  fixedSize: Size(150, 170), // 正方形按鈕
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),//0度是直角
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25), // 確保整個內容也有圓角
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 圖片部分
                      SizedBox(
                        height: 130,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          child: Image.asset(
                            'assets/image/a.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // 文字部分
                      Expanded(
                        child: Center(
                          child: Text(
                            '益智拼圖',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),//button3
                      ],
                    ),

                    SizedBox(width: 37),//左右兩欄間距

                    Column(
                      children: [
                        SizedBox(height: 30),//button2和手機的距離

                        ElevatedButton(
                          onPressed: () {
                            //ScaffoldMessenger.of(context).clearSnackBars();
                            //ScaffoldMessenger.of(context).showSnackBar(_snackBar1);
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Game2Page()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // 按鈕顏色
                            //minimumSize: Size(170, 170), // 按鈕尺寸
                            padding: EdgeInsets.zero, // 去除內距，圖片才會貼齊
                            fixedSize: Size(150, 170), // 正方形按鈕
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),//0度是直角
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25), // 確保整個內容也有圓角
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 圖片部分
                                SizedBox(
                                  height: 130,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                    child: Image.asset(
                                      'assets/image/a.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // 文字部分
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '看字選色',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),//button2

                        SizedBox(height: 33),//垂直間距

                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            //ScaffoldMessenger.of(context).showSnackBar(_snackBar1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // 按鈕顏色
                            //minimumSize: Size(170, 170), // 按鈕尺寸
                            padding: EdgeInsets.zero, // 去除內距，圖片才會貼齊
                            fixedSize: Size(150, 170), // 正方形按鈕
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),//0度是直角
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25), // 確保整個內容也有圓角
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 圖片部分
                                SizedBox(
                                  height: 130,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                    child: Image.asset(
                                      'assets/image/a.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // 文字部分
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '遊戲回顧',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),//button4
                      ],
                    ),
                  ],
                ),
              );
            },
          ),// 第 0 頁：「首頁」


          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const RemindPage()
                ],
              ),
            ),
          ),// 第 1 頁：「每日提醒」


          const AssessmentStartPage(), // 第 2 頁：「健康預測」


          const AlzheimerEduScreen(),// 第 3 頁：「衛教宣導」


          Center(child: Text('登入頁面')),// 第 4 頁：「登入」
        ],
      ),//頁面內容

    );  //主畫面
  }


}//所有頁面UI