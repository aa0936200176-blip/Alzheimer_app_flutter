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
      //headers: {"Content-Type": "application/json"}, // ✅ 預設加上 JSON
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

      return Map<String, dynamic>.from(response.data);

    } on DioException catch (e) {
      print("登入錯誤完整訊息 = $e");

      //是帳密錯誤（常見 400 / 401）
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw Exception('請輸入正確的帳號密碼');
      }

      // 其他錯誤（像斷線）
      throw Exception('登入失敗，請稍後再試');
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
        //'token': 'mock-jwt-token-xxx',
      };
    }

    // 前端防呆
    if (height < 140 || height > 200) {
      throw Exception('請輸入正確身高');
    }

    if (weight < 30 || weight > 150) {
      throw Exception('請輸入正確體重');
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
      // 錯誤訊息
      if (response.statusCode != 200) {
        if (data['detail'] != null && data['detail'] is List) {
          final detail = data['detail'][0];

          if (detail['loc'].toString().contains('height')) {
            throw Exception('身高格式錯誤（需 ≤ 250）');
          } else if (detail['loc'].toString().contains('weight')) {
            throw Exception('體重格式錯誤');
          }
        }

        throw Exception('註冊失敗，請確認輸入資料');
      }

      if (!data.containsKey('account')) {
        data['account'] = account;
      }

      return data;

    } on DioException catch (e) {
      print('註冊失敗：${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('網路錯誤，請稍後再試');
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
      },); // ← 改成 POST
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
