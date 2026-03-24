import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'evaluate_page.dart';

class ProfilePage extends StatefulWidget {
  final String account;
  final Function()? onLogout;
  final Future<void> Function()? onRefreshPredictions;
  const ProfilePage({super.key, this.onLogout, required this.account,this.onRefreshPredictions,});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  // 移除原本的 userData 依賴，改用狀態變數
  String name = '';
  String account = '';
  DateTime? birthday;
  double height = 0.0;
  double weight = 0.0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPredictions();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    _refreshPredictions(); // 每次頁面顯示都刷新
  }
  @override
  void dispose() {
    //routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 每次從其他頁面返回到 ProfilePage
  @override
  void didPopNext() {
    _refreshPredictions();
  }
  //預測結果
  List predictions = [];


  Future<void> _loadPredictions() async {
    try {
      final data = await ApiService().getPredictions(widget.account);
      if (!mounted) return;
      setState(() {
        predictions = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        predictions = [];
      });
    }
  }
  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService().getProfile(widget.account);

      setState(() {
        name = data['name'] as String? ?? '未知姓名';
        account = data['account'] as String? ?? '未知帳號';
        birthday = DateTime.tryParse(data['birthday'] as String? ?? '') ?? DateTime(2000);
        height = (data['height'] as num?)?.toDouble() ?? 160.0;
        weight = (data['weight'] as num?)?.toDouble() ?? 50.0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '無法載入個人資料：${e.toString()}';
      });

      // 可選：如果 401 未授權，直接登出
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        _logout();
      }
    }
  }
  Future<void> _refreshPredictions() async {
    try {
      final latestPredictions = await ApiService().getPredictions(widget.account);
      if (mounted) {
        setState(() {
          predictions = latestPredictions;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新預測結果失敗: $e')),
      );
    }
  }

  int get age {
    if (birthday == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthday!.year;
    if (today.month < birthday!.month ||
        (today.month == birthday!.month && today.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiLevel {
    if (bmi < 18.5) return '過輕';
    if (bmi < 24) return '正常';
    if (bmi < 27) return '過重';
    return '肥胖';
  }

  Future<void> _logout() async {
    try {
      // 1. 清除 API 的 token
      //ApiService().setToken(null);

      // 2. 清除本地儲存的 token（根據你實際使用的儲存方式）
      // 如果使用 flutter_secure_storage：
      // final storage = FlutterSecureStorage();
      // await storage.delete(key: 'auth_token');

      // 如果使用 shared_preferences（較不安全，但你原本就有用）：
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');     // 假設你存的是這個 key
      await prefs.remove('currentAccount'); // 保留你原本的清除

      // 3. 呼叫外部的登出回調（通常跳回登入頁）
      if (widget.onLogout != null) {
        widget.onLogout!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登出時發生錯誤：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('重新載入'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('登出'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('個人資料'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(child: ListTile(title: Text('姓名: $name'))),
            Card(child: ListTile(title: Text('帳號: $account'))),
            if (birthday != null)
              Card(
                child: ListTile(
                  title: Text(
                    '生日: ${birthday!.year}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            Card(child: ListTile(title: Text('年齡: $age 歲'))),
            Card(child: ListTile(title: Text('身高: ${height.toStringAsFixed(1)} cm'))),
            Card(child: ListTile(title: Text('體重: ${weight.toStringAsFixed(1)} kg'))),
            Card(
              child: ListTile(
                title: Text('BMI: ${bmi.toStringAsFixed(1)} ($bmiLevel)'),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('登出', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}