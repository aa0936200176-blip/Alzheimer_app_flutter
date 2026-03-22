import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';//遊戲訓練
import 'home_page_review.dart';//遊戲回顧
import 'remind_page.dart';//每日提醒(日曆)
import 'evaluate_page.dart';//問卷評估
import 'login_page.dart';//登入
import 'healthedu_page.dart';//衛教宣導
import 'profile_page.dart';//註冊
import 'api.dart';
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(
        onLoginSuccess: (user) {

          // 導航到主畫面
          print("登入成功：${user['account']}");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainPage(initialUser: user),
            ),
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  //const MainPage({super.key});
  final Map<String, dynamic>? initialUser;

  const MainPage({super.key, this.initialUser});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 用來判斷是否已登入
  bool _isLoggedIn = false;

  // 如果想顯示使用者名稱在 AppBar，可存這裡
  String? _userName;
  String? _account;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      setState(() {
        _isLoggedIn = true;
        _userName = widget.initialUser!['name'] as String?;
        _account = widget.initialUser!['account'] as String?;
        currentUser = widget.initialUser;
        _selectedIndex = 0;  // 或 4
      });
    }
    _checkLoginStatus();
  }

  //檢查是否已登入
  Future<void> _checkLoginStatus() async {
    // 用 ApiService 內部的 token 判斷
    try {
      final profile = await ApiService().getProfile(_account!);
      setState(() {
        _isLoggedIn = true;
        _userName = profile['name'] as String?;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      if (_isLoggedIn) {
        // 已登入 → 直接切換到會員中心 tab，顯示 ProfilePage
        setState(() => _selectedIndex = 4);
      } else{
        // 未登入 → 推登入頁
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              onLoginSuccess: (user) async {
                //print('登入成功回調執行！user = $user');
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('currentAccount', user['account']);
                setState(() {
                  _isLoggedIn = true;
                  _userName = user['name'] as String?;
                  _account = user['account'] as String?;   //接收 account
                  currentUser = user;  // 如果有這個變數就更新
                  _selectedIndex = 4;
                });

                // 登入成功後：留在會員中心（顯示 ProfilePage）
                // 如果想登入後跳回首頁，就改成 _selectedIndex = 0;

                // 回到主畫面
                Navigator.pop(context);
              },
            ),
          ),
        );
        return;
      }
    }
    setState(() => _selectedIndex = index);
  }

  Widget _buildBody() {
    if (_selectedIndex == 4) {
      if (currentUser != null) {
        // 已登入 → 顯示 ProfilePage
        // 個人資料頁（已登入狀態）
        return ProfilePage(
          key: ValueKey(_account),
          account: _account!,
          //routeObserver: routeObserver,
          onLogout: () {
            setState(() {
              _isLoggedIn = false;
              _userName = null;
              _account = null;
              currentUser = null;
              _selectedIndex = 0; // 登出後跳回首頁
            });
            // 更新 UI 狀態
          },
        );
      }else {
        // 未登入 → 顯示 LoginPage
        return LoginPage(
          showRegister: true,
          onLoginSuccess: (user) {
            setState(() {
              currentUser = user;
              _isLoggedIn = true;
              _account = user['account']?.toString();
              _userName = user['name']?.toString();
              currentUser = user;
              _selectedIndex = 4; // 登入後停留在個人資料頁
            });
          },
        );
      }
    }

    // 其他頁面用 IndexedStack 保持狀態
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildHomePage(),               // 0: 首頁遊戲
        const RemindPage(),             // 1: 每日提醒
        const AssessmentStartPage(),    // 2: 健康預測
        const AlzheimerEduScreen(),     // 3: 衛教
        const SizedBox.shrink(),        // 4: 個人資料
      ],
    );
  }

  Widget _buildHomePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildGameButton('記憶翻牌', 'assets/image/game1.png', (acc) => GameLevelPage(account: acc)),
            _buildGameButton('益智拼圖', 'assets/image/game2.png', (acc) => PuzzleGamePage(account: acc)),
            _buildGameButton('看字選色', 'assets/image/game3.jpg', (acc) => Game2Page(account: acc)),
            _buildGameButton('遊戲回顧', 'assets/image/review.png', (acc) => GameReviewPage(account: acc)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(String title, String imagePath, Widget Function(String) pageBuilder) {
    return ElevatedButton(
      onPressed: () {
        if (!_isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('請先登入才能遊玩遊戲')),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => pageBuilder(_account ?? '訪客')), //傳入account
        );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _isLoggedIn && _userName != null
            ? [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('歡迎，$_userName', style: const TextStyle(fontSize: 16)),
          ),
        ]
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: '會員'),
        ],
      ),
    );
  }
}

// 標題列表
const List<String> _titles = [
  '認知訓練遊戲',
  '每日提醒設定',
  '問卷風險預測',
  '衛教宣導',
  '會員中心',
];