import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';//遊戲訓練
import 'home_page_review.dart';//遊戲回顧
import 'remind_page.dart';//每日提醒(日曆)
import 'evaluate_page.dart';//問卷評估
import 'login_page.dart';//登入
import 'healthedu_page.dart';//衛教宣導
import 'db_helper.dart';//註冊的資料庫
import 'profile_page.dart';//註冊


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "阿茲海默風險預測App",
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPage(),
    );
  }
}


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;//底部導航欄
  Map<String, dynamic>? currentUser;
  final DBHelper dbHelper = DBHelper();


  final List<String> _titles = [
    '遊戲訓練',
    '每日提醒設定',
    '阿茲海默風險預測',
    '衛教宣導',
    '登入/註冊',
  ];// 用來顯示不同頁面的標題


  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString('currentAccount');
    if (account != null) {
      final user = await dbHelper.getUser(account);
      if (user != null) {
        setState(() => currentUser = user);
      }
    }
  }

  void _onItemTap(int index) {
    setState(() => _selectedIndex = index);

  }

  Widget _buildHomePage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: GridView.count(
          shrinkWrap: true, //讓 GridView 根據內容縮小高度
          physics: const NeverScrollableScrollPhysics(),//讓按鈕區域不可滑動
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildGameButton(context, '記憶翻牌', 'assets/image/game1.png', const GameLevelPage()),
            _buildGameButton(context, '益智拼圖', 'assets/image/game2.png', PuzzleGamePage()),
            _buildGameButton(context, '看字選色', 'assets/image/game3.jpg', const Game2Page()),
            _buildGameButton(context, '遊戲回顧', 'assets/image/review.png', const GameReviewPage()),
          ],
        ),
      ),
    );
  }// 首頁四個遊戲按鈕

  Widget _buildGameButton(BuildContext context, String title, String imagePath, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        padding: EdgeInsets.zero,
        fixedSize: const Size(150, 170),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 130,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }// 首頁四個遊戲按鈕顏色大小


  @override
  Widget build(BuildContext context) {
    Widget body;

    // 第 4 頁：登入/註冊/個人資料
    if (_selectedIndex == 4) {
      body = currentUser != null
          ? ProfilePage(
        userData: currentUser!,
        onLogout: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('currentAccount');
          setState(() {
            currentUser = null;
            _selectedIndex = 4; // 回到登入頁
          });
        },
      )
          : LoginPage(
        showRegister: true,
        onLoginSuccess: (user) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentAccount', user['account']);
          setState(() {
            currentUser = user;
            _selectedIndex = 4;
          });
        },
      );
    } else {
      // 其他頁面用 IndexedStack 保留狀態
      body = IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(context),   // 第 0 頁：首頁遊戲
          RemindPage(),              // 第 1 頁：每日提醒
          const AssessmentStartPage(), // 第 2 頁：健康預測
          const AlzheimerEduScreen(),  // 第 3 頁：衛教
          const SizedBox.shrink(),     // 占位，第 4 頁判斷上面
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 18,
        unselectedFontSize: 14,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.add_alert_outlined), label: '每日提醒'),
          BottomNavigationBarItem(icon: Icon(Icons.accessibility), label: '健康預測'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: '衛教宣導'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: '登入'),
        ],
      ),
    );
  }


}//所有頁面UI