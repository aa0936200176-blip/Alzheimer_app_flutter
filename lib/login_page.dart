import 'package:flutter/material.dart';
import 'api.dart';
import 'main.dart';
import 'home_page.dart';


class LoginPage extends StatefulWidget {
  final Function(Map<String, dynamic> user) onLoginSuccess;
  final bool showRegister;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    this.showRegister = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginMode = true;
  bool _isLoading = false;

  bool _isLoggedIn = false;
  String account = '';
  // 登入
  final _loginAccountController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // 註冊
  final _regAccountController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedBirthday;

  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();

    isLoginMode = !widget.showRegister;

    // 模擬模式
    //_apiService = ApiService(useMock: true);

    // 後端完成後改成
    _apiService = ApiService(useMock: false);
  }

  Future<void> _pickBirthday() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // ======================
  // 登入
  // ======================

  Future<void> _login() async {

    final loginAccount = _loginAccountController.text.trim(); // 改名避免遮蔽
    final password = _loginPasswordController.text.trim();

    if (loginAccount.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入帳號與密碼')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _apiService.login(loginAccount, password);
      //print("登入成功 user = $user");
      // 成功後直接跳轉到 MainPage，並傳入 user 資訊
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(initialUser: user), // 需要在 MainPage 支援 initialUser
          ),
        );
      }
    }
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登入失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================
  // 註冊
  // ======================

  Future<void> _register() async {
    final regaccount = _regAccountController.text.trim();
    final password = _regPasswordController.text.trim();
    final name = _nameController.text.trim();
    final birthday = _birthdayController.text;
    final heightStr = _heightController.text.trim();
    final weightStr = _weightController.text.trim();

    if ([regaccount, password, name, birthday, heightStr, weightStr]
        .any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫完整資料')),
      );
      return;
    }

    final height = double.tryParse(heightStr) ?? 160;
    final weight = double.tryParse(weightStr) ?? 50;

    setState(() {_isLoading = true; });

    try {
      final user = await _apiService.register(
        account: regaccount,
        password: password,
        name: name,
        birthday: birthday,
        height: height,
        weight: weight,
      );

      if (mounted) {
        Future.microtask(() {
          widget.onLoginSuccess(user);
        }); }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('註冊成功')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('註冊失敗：$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(isLoginMode ? '登入' : '註冊'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              if (isLoginMode) ...[
                TextField(
                  controller: _loginAccountController,
                  decoration: const InputDecoration(
                    labelText: '帳號',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _loginPasswordController,
                  decoration: const InputDecoration(
                    labelText: '密碼',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('登入'),
                ),
              ]

              else ...[
                TextField(
                  controller: _regAccountController,
                  decoration: const InputDecoration(
                    labelText: '帳號',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _regPasswordController,
                  decoration: const InputDecoration(
                    labelText: '密碼',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _birthdayController,
                  readOnly: true,
                  onTap: _pickBirthday,
                  decoration: const InputDecoration(
                    labelText: '生日',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '身高(cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '體重(kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('註冊'),
                ),
              ],

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  setState(() {
                    isLoginMode = !isLoginMode;
                  });
                },
                child: Text(
                  isLoginMode ? '還沒有帳號？註冊' : '已有帳號？登入',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("主選單"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("歡迎 $account"),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  GameLevelPage(account: account)),
              ),
              child: const Text("記憶翻牌"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  Game2Page(account: account)),
              ),
              child: const Text("看字選色"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  PuzzleGamePage(account: account)),
              ),
              child: const Text("拼圖遊戲"),
            ),
          ],
        ),
      ),
    );
  }

}