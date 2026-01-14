import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function()? onLogout;

  const ProfilePage({super.key, required this.userData, this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name;
  late DateTime birthday;
  late double height;
  late double weight;

  @override
  void initState() {
    super.initState();
    name = widget.userData['name'];
    birthday = DateTime.parse(widget.userData['birthday']);
    height = widget.userData['height'];
    weight = widget.userData['weight'];
  }

  int get age {
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month || (today.month == birthday.month && today.day < birthday.day)) {
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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentAccount');
    if (widget.onLogout != null) widget.onLogout!();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(child: ListTile(title: Text('姓名: $name'))),
          Card(child: ListTile(title: Text('帳號: ${widget.userData['account']}'))),
          Card(child: ListTile(title: Text('生日: ${birthday.year}-${birthday.month}-${birthday.day}'))),
          Card(child: ListTile(title: Text('年齡: $age 歲'))),
          Card(child: ListTile(title: Text('身高: $height cm'))),
          Card(child: ListTile(title: Text('體重: $weight kg'))),
          Card(child: ListTile(title: Text('BMI: ${bmi.toStringAsFixed(1)} ($bmiLevel)'))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _logout, child: const Text('登出')),
        ],
      ),
    );
  }
}