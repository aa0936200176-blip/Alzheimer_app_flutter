import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode


class ApiService {
  static const String baseUrl = 'http://120.125.78.193:8048';
  //static const String baseUrl = 'http://himhealth.mcu.edu.tw:8048';
  final bool useMock;
  late final Dio _dio;

  ApiService({this.useMock = false}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }


  // 登入：POST /auth/login
  Future<Map<String, dynamic>> login(String account, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'account': account,
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);}
    on DioException catch (e) {
      print("登入錯誤完整訊息 = $e");
      rethrow;
    }
  }

  // 註冊：POST /auth/register
  Future<Map<String, dynamic>> register({
    required String account,
    required String password,
    required String name,
    required String birthday,
    required double height,
    required double weight,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'account': account,
        'name': name,
        'birthday': birthday,
        'height': height,
        'weight': weight,
      };
    }

    try {
      print('【REGISTER】準備發送請求到：$baseUrl/auth/register');
      print('送出資料：account=$account, name=$name, birthday=$birthday, height=$height, weight=$weight');
      final response = await _dio.post('/auth/register', data: {
        'account': account,
        'password': password,
        'name': name,
        'birthday': birthday,
        'height': height,
        'weight': weight,
      },options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
      );
      print('【REGISTER】後端回應狀態碼：${response.statusCode}');
      print('【REGISTER】後端回應內容：${response.data}');

      final data = Map<String, dynamic>.from(response.data);
      // 失敗時手動丟錯誤
      if (response.statusCode != 200) {
        throw Exception('後端回傳錯誤：${data['detail'] ?? response.statusCode}');
      }
      if (!data.containsKey('account')) {
        data['account'] = account; // 如果後端沒回傳 account，就自己補
      }

      return data;
    } on DioException catch (e) {
      print('註冊失敗：${e.response?.statusCode} - ${e.response?.data}');
      print('【REGISTER】Dio 錯誤！！');
      print('錯誤類型: ${e.type}');
      print('錯誤訊息: ${e.message}');
      if (e.response != null) {
        print('回應狀態碼: ${e.response?.statusCode}');
        print('回應資料: ${e.response?.data}');
        print('回應 headers: ${e.response?.headers}');
      } else {
        print('沒有收到任何回應（response == null）');
        print('可能是連線拒絕、timeout 或 DNS 問題');
      }
      rethrow;
    }
  }

  // 取得個人資料：改成 POST /users/me（後端是 POST！）
  Future<Map<String, dynamic>> getProfile(String account) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'account': 'test123',
        'name': '測試使用者',
        'birthday': '2000-01-01',
        'height': 170.0,
        'weight': 60.0,
      };
    }

    try {
      final response = await _dio.post('/users/me',data: {
        'account': account,
      },); // 改成 POST
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('取得個人資料失敗：${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 405) {
        print('警告：後端 /users/me 只允許 POST 方法，但你用了 GET');
      }
      rethrow;
    }
  }
  // 預測結果：POST /users/predictions
  Future<List<dynamic>> getPredictions(String account) async {
    final response = await _dio.post(
      "/users/predictions",
      data: {
        "account": account
      },
    );
    return response.data;
  }
  Future<Map<String, dynamic>> predict(Map<String, dynamic> data, String account) async {

    final response = await _dio.post(
      "/v1/predict_and_log",
      data: {
        "account": account,
        "data": data
      },
    );

    return Map<String, dynamic>.from(response.data);
  }
  // 遊戲歷史紀錄：POST /games/result
  Future<void> saveGameResult({
    required String account,
    required String gameType,
    required int score,
    required int seconds,
    required int level,
  }) async {
    try {
      await _dio.post('/games/result', data: {
        'account': account,
        'gameType': gameType,
        'score': score,
        'seconds': seconds,
        'level': level,
      });
      print('遊戲紀錄上傳成功');
    } catch (e) {
      print('遊戲紀錄上傳失敗：$e');
    }
  }
  // 遊戲歷史紀錄：POST /games/history（後端是 POST）
  Future<List<Map<String, dynamic>>> getGameHistory(String account,
      String gameType,) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return List.generate(5, (i) =>
      {
        'score': 80 + i * 5,
        'seconds': 120 - i * 10,
        'level': 3 + i,
        'playedAt': DateTime.now()
            .subtract(Duration(days: i))
            .toIso8601String(),
      });
    }

    try {
      final response = await _dio.post(
        '/games/history',
        data: {
          'account': account,
          'gameType': gameType,
        },
      );

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('取得遊戲歷史失敗：${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }
}
// 未來其他 API 方法也可以用同樣方式加模擬