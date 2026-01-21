import 'package:flutter/material.dart';
import 'db_helper.dart';

class LoginPage extends StatefulWidget {
  final Function(Map<String, dynamic> user) onLoginSuccess;
  final bool showRegister;

  const LoginPage({super.key, required this.onLoginSuccess, this.showRegister = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginMode = true;
  final DBHelper dbHelper = DBHelper();

  final _loginAccountController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _regAccountController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedBirthday;

  @override
  void initState() {
    super.initState();
    isLoginMode = !widget.showRegister; // showRegister 為 true 顯示註冊頁
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(isLoginMode ? '登入' : '註冊', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          // 登入
          if (isLoginMode) ...[
            TextField(controller: _loginAccountController, decoration: const InputDecoration(labelText: '帳號')),
            const SizedBox(height: 16),
            TextField(controller: _loginPasswordController, decoration: const InputDecoration(labelText: '密碼'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final account = _loginAccountController.text.trim();
                final password = _loginPasswordController.text;
                final user = await dbHelper.getUser(account);
                if (user != null && user['password'] == password) {
                  widget.onLoginSuccess(user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('帳號或密碼錯誤')));
                }
              },
              child: const Text('登入'),
            ),
          ],

          // 註冊
          if (!isLoginMode) ...[
            TextField(controller: _regAccountController, decoration: const InputDecoration(labelText: '帳號')),
            const SizedBox(height: 16),
            TextField(controller: _regPasswordController, decoration: const InputDecoration(labelText: '密碼'), obscureText: true),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '姓名')),
            const SizedBox(height: 16),
            TextField(
              controller: _birthdayController,
              readOnly: true,
              decoration: const InputDecoration(labelText: '生日'),
              onTap: _pickBirthday,
            ),
            const SizedBox(height: 16),
            TextField(controller: _heightController, decoration: const InputDecoration(labelText: '身高 (cm)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _weightController, decoration: const InputDecoration(labelText: '體重 (kg)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final account = _regAccountController.text.trim();
                final password = _regPasswordController.text;
                final name = _nameController.text.trim();
                final birthday = _birthdayController.text;
                final height = double.tryParse(_heightController.text) ?? 160;
                final weight = double.tryParse(_weightController.text) ?? 50;

                if (account.isEmpty || password.isEmpty || name.isEmpty || birthday.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請填完整資料')));
                  return;
                }

                final exists = await dbHelper.getUser(account);
                if (exists != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('帳號已存在')));
                  return;
                }

                await dbHelper.insertUser({
                  'account': account,
                  'password': password,
                  'name': name,
                  'birthday': birthday,
                  'height': height,
                  'weight': weight,
                });

                final newUser = await dbHelper.getUser(account);
                if (newUser != null) widget.onLoginSuccess(newUser);
              },
              child: const Text('註冊'),
            ),
          ],

          TextButton(
            onPressed: () => setState(() => isLoginMode = !isLoginMode),
            child: Text(isLoginMode ? '還沒有帳號？註冊' : '已有帳號？登入'),
          ),
        ],
      ),
    );
  }
}