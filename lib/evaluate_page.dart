import 'package:alzheimer_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // 用來轉 JSON
import 'package:http/http.dart' as http; // 用來發送請求


// =======================
// 1. 資料模型 (儲存所有分數)
// =======================
class AssessmentResult {
  // Memory Complaints
  int memoryScore = 0; // 0 or 1

  // ADL
  int adlScore = 0; // 0 ~ 100

  // Sleep Quality
  int sleepScore = 0; // 4 ~ 10

  // MMSE [cite: 17, 23]
  int mmseScore = 0; // 0 ~ 30

  // Behavioral Problems
  int behaviorScore = 0; // 0 or 1

  //Functional Assessment
  int functionScore = 0;// 1 ~ 10

  @override
  String toString() {
    return 'Memory Complaints(記憶抱怨): $memoryScore\nADL日常生活活動量表: $adlScore\nSleep Quality(睡眠品質): $sleepScore\nMMSE(簡易心智量表): $mmseScore\nBehavioralProblems(行為問題): $behaviorScore\nFunctional Assessment(整體功能評分): $functionScore';
  }
}

// =======================
// 2. 開始頁面
// =======================
class AssessmentStartPage extends StatelessWidget {
  const AssessmentStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_ind, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("請依序回答接下來的 6 份問卷", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AssessmentFlowPage()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Text("開始進行測驗", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================
// 3. 問卷主流程 (PageView)
// =======================
class AssessmentFlowPage extends StatefulWidget {
  const AssessmentFlowPage({super.key});

  @override
  State<AssessmentFlowPage> createState() => _AssessmentFlowPageState();
}

class _AssessmentFlowPageState extends State<AssessmentFlowPage> {
  final PageController _controller = PageController();
  final AssessmentResult _result = AssessmentResult();
  int _currentPage = 0;
  final int _totalPages = 6;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage++;
      });
    } else {
      _submitResults();
    }
  }

  // async 方法，因為網路請求是異步的
  Future<void> _submitResults() async {
    // 1. 顯示載入中的轉圈圈
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // 2. 打包數據
    // 要看 API 的欄位名稱
    final Map<String, dynamic> requestData = {
      "Age":60,
      "BMI":22.5,

      "MemoryComplaints": _result.memoryScore,
      "ADL": _result.adlScore / 10,
      "SleepQuality": _result.sleepScore,
      "MMSE": _result.mmseScore,
      "BehavioralProblems": _result.behaviorScore,
      "FunctionalAssessment": _result.functionScore
    };

    //API 指定要放在 "data" 裡面
    final Map<String, dynamic> requestBody = {
      "data": requestData
    };

    try {
      // 3. 發送 API 請求
      final Uri url = Uri.parse("http://himhealth.mcu.edu.tw:8048/v1/predict");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody), // 將 Map 轉為 JSON 字串
      );

      // 關閉載入中的轉圈圈
      if (mounted) Navigator.pop(context);

      // 4. 檢查伺服器回應
      if (response.statusCode == 200 || response.statusCode == 201) {

        // 1. 解碼 JSON
        final responseData = jsonDecode(response.body);

        // 2. 讀取關鍵數據
        // 注意：根據您的 Log，欄位名稱是 'prediction' 和 'risk_probability'
        int prediction = responseData['prediction'];
        double probability = responseData['risk_probability'];

        print("解析成功 - 結果: $prediction, 機率: $probability");

        // 3. 呼叫彈出視窗，把這兩個數字傳進去
        _showSuccessDialog(prediction, probability);

      } else {

        print("上傳失敗，狀態碼: ${response.statusCode}");
        print("伺服器回應錯誤訊息: ${response.body}");

        _showErrorSnackBar("上傳失敗: ${response.statusCode}");
      }
    } catch (e) {
      // 關閉載入中
      if (mounted) Navigator.pop(context);
      // 網路連線異常
      _showErrorSnackBar("連線錯誤：$e");
    }
  }

  // 顯示結果(接收預測結果和機率)
  void _showSuccessDialog(int prediction, double probability) {

    // 1. 判斷邏輯：如果是 1 就是高風險
    bool isHighRisk = (prediction == 1);

    // 2. 設定顏色與文字
    // 高風險用紅色，低風險用綠色
    Color themeColor = isHighRisk ? Colors.red : Colors.green;
    String titleText = isHighRisk ? "風險預警" : "評估完成";
    IconData titleIcon = isHighRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    String messageText = isHighRisk
        ? "模型分析顯示您可能有潛在的阿茲海默症風險。\n建議您儘速前往神經內科或精神科進行詳細檢查。"
        : "模型分析顯示目前的風險較低。\n請繼續保持良好的生活習慣與運動！";

    // 3. 把機率變成百分比
    String probString = "${(probability * 100).toStringAsFixed(1)}%";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // 標題區
        title: Row(
          children: [
            Icon(titleIcon, color: themeColor, size: 28),
            const SizedBox(width: 10),
            Text(
              titleText,
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // 內容區
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              // --- 顯示機率的大框框 ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1), // 淺色背景
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: themeColor.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text("預測患病機率", style: TextStyle(color: themeColor, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      probString,
                      style: TextStyle(
                          color: themeColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 建議文字 ---
              Text(messageText, style: const TextStyle(fontSize: 16, height: 1.5)),
              const Divider(height: 30, thickness: 1),

              // --- 原始分數列表 (讓使用者核對) ---
              const Text("本次評估數據：", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildScoreRow("MMSE (心智量表)", "${_result.mmseScore}"),
              _buildScoreRow("ADL (生活功能)", "${_result.adlScore}"), // 顯示原始分數
              _buildScoreRow("功能評估", "${_result.functionScore}"),
              _buildScoreRow("記憶抱怨", "${_result.memoryScore}"),
              _buildScoreRow("睡眠品質", "${_result.sleepScore}"),
              _buildScoreRow("行為問題", "${_result.behaviorScore}"),
            ],
          ),
        ),
        // 按鈕區
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // 關閉 Dialog
              Navigator.of(context).pop(); // 回到首頁
            },
            child: const Text("完成，回到首頁", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // 小工具：用來排版每一行分數
  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  // 顯示錯誤的輔助方法
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("問卷 ${_currentPage + 1} / $_totalPages"),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(), // 禁止手動滑動，強制用按鈕
              children: [
                MemoryComplaintsForm(
                  onSaved: (val) => _result.memoryScore = val,
                  onNext: _nextPage,
                ),
                ADLForm(
                  onSaved: (val) => _result.adlScore = val,
                  onNext: _nextPage,
                ),
                SleepQualityForm(
                  onSaved: (val) => _result.sleepScore = val,
                  onNext: _nextPage,
                ),
                MMSEForm(
                  onSaved: (val) => _result.mmseScore = val,
                  onNext: _nextPage,
                ),
                BehavioralProblemsForm(
                  onSaved: (val) => _result.behaviorScore = val,
                  onSubmit: _nextPage,
                ),
                FunctionalAssessmentForm(
                  onSaved: (val) => _result.functionScore = val,
                  onSubmit: _submitResults, // 最後一份直接送出
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =======================
// 4. 個別問卷 Widget
// =======================

// --- A. Memory Complaints (記憶抱怨) ---
class MemoryComplaintsForm extends StatefulWidget {
  final Function(int) onSaved;
  final VoidCallback onNext;

  const MemoryComplaintsForm({super.key, required this.onSaved, required this.onNext});

  @override
  State<MemoryComplaintsForm> createState() => _MemoryComplaintsFormState();
}

class _MemoryComplaintsFormState extends State<MemoryComplaintsForm> {

  final List<String> options = [
    "經常忘記剛發生的事情",
    "常忘記約定的時間或地點",
    "需要反覆確認或依賴他人提醒",
    "覺得自己的記憶力比以前明顯變差"
  ];//Memory Complaints題目

  List<bool> checks = [false, false, false, false];
  bool noneOfAbove = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Memory Complaints 記憶抱怨問卷",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("在最近一個月內，您是否曾出現以下記憶相關困擾？(可複選)", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          ...List.generate(options.length, (index) {
            return CheckboxListTile(
              title: Text(options[index]),
              value: checks[index],
              onChanged: (val) {
                setState(() {
                  checks[index] = val!;
                  if (val) noneOfAbove = false;
                });
              },
            );
          }),
          CheckboxListTile(
            title: const Text("以上皆無"),
            value: noneOfAbove,
            onChanged: (val) {
              setState(() {
                noneOfAbove = val!;
                if (val) checks = [false, false, false, false];
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // 計分邏輯: 若勾選任一項(前4項) -> 1，若勾選以上皆無 -> 0
                int score = checks.contains(true) ? 1 : 0;
                widget.onSaved(score);
                widget.onNext();
              },
              child: const Text("完成Memory Complaints評估 下一頁"),
            ),
          )
        ],
      ),
    );
  }//Memory Complaints

}


// --- B. ADL (日常生活活動量表) ---
class ADLForm extends StatefulWidget {
  final Function(int) onSaved;
  final VoidCallback onNext;

  const ADLForm({super.key, required this.onSaved, required this.onNext});

  @override
  State<ADLForm> createState() => _ADLFormState();
}

class _ADLFormState extends State<ADLForm> {

  final List<Map<String, dynamic>> questions = [
    {
      "title": "1.進食",
      "options":[
        {"score": 10, "text": "可自行在合理時間內(約10秒吃一口)用筷子取食；若需輔具可自行穿脫。"},
        {"score": 5, "text": "需別人幫忙穿脫輔具或只會用湯匙進食，或需人協助夾菜。"},
        {"score": 0, "text": "無法自行取食，需他人餵食或耗時過長。"},
      ]
    },
    {
      "title": "2.洗澡",
      "options": [
        {"score": 5, "text": "可獨立完成(盆浴或淋浴)，不需別人在旁。"},
        {"score": 0, "text": "需別人協助或監護。"}
      ]
    },
    {
      "title": "3. 個人衛生 (洗臉/刷牙/梳頭/刮鬍子)",
      "options": [
        {"score": 5, "text": "可獨立完成所有動作。"},
        {"score": 0, "text": "需別人協助。"}
      ]
    },
    {
      "title": "4. 穿脫衣服 (含鞋襪)",
      "options": [
        {"score": 10, "text": "可自行穿脫衣服、褲子、鞋子、及輔具等。"},
        {"score": 5, "text": "在別人協助下，可自行完成一半以上的動作。"},
        {"score": 0, "text": "需別人協助。"}
      ]
    },
    {
      "title": "5. 排便控制",
      "options": [
        {"score": 10, "text": "不會失禁，若需使用塞劑可自行完成。"},
        {"score": 5, "text": "偶爾會失禁(每週不超過一次)，或使用塞劑時需協助。"},
        {"score": 0, "text": "完全失禁或需完全協助。"}
      ]
    },
    {
      "title": "6. 排尿控制",
      "options": [
        {"score": 10, "text": "日夜皆不會尿失禁，或可自行處理尿套/尿布。"},
        {"score": 5, "text": "偶爾會尿失禁(每週不超過一次)或尿急(無法等待便盆或無法及時趕到廁所)或需別人幫忙處理尿套。"},
        {"score": 0, "text": "完全失禁或需完全協助。"}
      ]
    },
    {
      "title": "7. 如廁",
      "options": [
        {"score": 10, "text": "可自行進出廁所、穿脫褲子、清理，不需協助。"},
        {"score": 5, "text": "需協助保持平衡、整理衣物或使用衛生紙，使用便盆者，可自行取放便盆但須仰賴他人清理。"},
        {"score": 0, "text": "需完全協助。"}
      ]
    },
    {
      "title": "8. 移位 (輪椅與床位間的移動)",
      "options": [
        {"score": 15, "text": "可獨立完成，包含煞住輪椅及移開腳踏板。"},
        {"score": 10, "text": "需要些微協助(如予以輕扶以保持平衡)或口頭指導。"},
        {"score": 5, "text": "可自行坐起，但需人協助移位。"},
        {"score": 0, "text": "需別人協助可坐起來或需要兩人幫忙方可移位。"}
      ]
    },
    {
      "title": "9. 步行",
      "options": [
        {"score": 15, "text": "使用或不使用輔具皆可獨立行走 50 公尺以上。"},
        {"score": 10, "text": "需要稍微扶持或口頭指導方可行走 50 公尺以上。"},
        {"score": 5, "text": "雖無法行走，但可獨自操縱輪椅(包括轉彎、進門、及接近桌子、床沿)並可推行輪椅 50 公尺以上。"},
        {"score": 0, "text": "完全依賴他人推輪椅或無法移動。"}
      ]
    },
    {
      "title": "10. 上下樓梯",
      "options": [
        {"score": 10, "text": "可獨立上下樓梯(可抓扶手或用柺杖)。"},
        {"score": 5, "text": "需予協助或口頭指導。"},
        {"score": 0, "text": "無法上下樓梯。"}
      ]
    },
  ];//ADL題目

  late List<int?> selectedScores;

  @override
  void initState() {
    super.initState();
    selectedScores = List.filled(questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ADL 日常生活活動量表", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("請點選最符合個案狀況的描述", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Divider(thickness: 2),

          // 動態產生題目列表
          ...List.generate(questions.length, (index) {
            var q = questions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 題目標題
                    Text(
                        q['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                    ),
                    const SizedBox(height: 8),
                    // 選項列表
                    Column(
                      children: (q['options'] as List).map<Widget>((opt) {
                        return RadioListTile<int>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(opt['text'], style: const TextStyle(fontSize: 15)),
                          subtitle: Text("得分: ${opt['score']}", style: const TextStyle(color: Colors.grey)),
                          value: opt['score'],
                          groupValue: selectedScores[index],
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            setState(() {
                              selectedScores[index] = val;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // 檢查是否所有題目都已填寫
                if (selectedScores.contains(null)) {
                  // 找出沒填的題目
                  int firstUnanswered = selectedScores.indexOf(null);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("第 ${firstUnanswered + 1} 題尚未作答，請完成所有題目"),
                        backgroundColor: Colors.red,
                      )
                  );
                  return;
                }

                int total = selectedScores.fold(0, (sum, item) => sum + (item ?? 0));
                widget.onSaved(total);
                widget.onNext();
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18)
              ),
              child: const Text("完成 ADL 評估，下一頁"),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }//ADL

}


// --- C. Sleep Quality (睡眠品質) ---
class SleepQualityForm extends StatefulWidget {
  final Function(int) onSaved;
  final VoidCallback onNext;

  const SleepQualityForm({super.key, required this.onSaved, required this.onNext});

  @override
  State<SleepQualityForm> createState() => _SleepQualityFormState();
}

class _SleepQualityFormState extends State<SleepQualityForm> {
  int? selectedScore;


  final List<Map<String, dynamic>> options = [
    {"score": 10, "text": "入睡容易，整晚幾乎沒有醒來，起床後感覺精神充足"},
    {"score": 9, "text": "偶爾醒來一次，但不影響整體睡眠品質"},
    {"score": 8, "text": "偶爾難以入睡或中途醒來，但隔天仍可正常活動"},
    {"score": 7, "text": "入睡時間較長，或夜間醒來 1-2 次"},
    {"score": 6, "text": "睡眠中斷明顯，起床後稍感疲倦"},
    {"score": 5, "text": "常常睡不好，白天容易疲倦或想睡"},
    {"score": 4, "text": "嚴重睡眠困擾，幾乎每天睡眠不足或品質極差"},
  ];//Sleep Quality題目

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sleep Quality 睡眠品質量表",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("請問您整體的睡眠品質如何？", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          ...options.map((opt) {
            return RadioListTile<int>(
              title: Text("${opt['score']}分 - ${opt['text']}"),
              value: opt['score'],
              groupValue: selectedScore,
              onChanged: (val) {
                setState(() {
                  selectedScore = val;
                });
              },
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (selectedScore == null) return;
                widget.onSaved(selectedScore!);
                widget.onNext();
              },
              child: const Text("完成Sleep Quality評估 下一頁"),
            ),
          )
        ],
      ),
    );
  }//Sleep Quality

}


// --- D. MMSE (簡易心智量表) ---
class MMSEForm extends StatefulWidget {
  final Function(int) onSaved;
  final VoidCallback onNext;

  const MMSEForm({super.key, required this.onSaved, required this.onNext});

  @override
  State<MMSEForm> createState() => _MMSEFormState();
}

class _MMSEFormState extends State<MMSEForm> {

  final List<Map<String, dynamic>> questions = [
    {
      "title": "1. 定向感 (時間)",
      "maxScore": 5,
      "description": "請詢問個案：\n「今年是幾年？現在是幾月？今天是幾號？星期幾？現在是什麼季節？」",
      "hint": "每答對一項得 1 分，共 5 分"
    },
    {
      "title": "2. 定向感 (地方)",
      "maxScore": 5,
      "description": "請詢問個案：\n「我們現在在哪個縣市？在哪家醫院(或診所)？什麼科別(或病房)？在第幾樓？這裡是哪裡(如診間)？」",
      "hint": "每答對一項得 1 分，共 5 分"
    },
    {
      "title": "3. 訊息登錄 (記憶)",
      "maxScore": 3,
      "description": "請清楚唸出三個名詞（如：皮球、國旗、樹木），每秒唸一個。\n唸完後請個案複誦一次，並請他記住，稍後會再問。",
      "hint": "個案能說出一個得 1 分，共 3 分 (第一次嘗試的結果)"
    },
    {
      "title": "4. 注意力與計算",
      "maxScore": 5,
      "description": "請個案從 100 開始連續減 7。\n(93、86、79、72、65)\n\n※若個案無法計算，可改請他倒著唸「台南火車站」(站車火南台)。",
      "hint": "每減對一次(或倒唸對一個字)得 1 分，共 5 分"
    },
    {
      "title": "5. 回憶 (記憶力)",
      "maxScore": 3,
      "description": "請個案說出剛剛要他記住的那三個名詞是什麼？",
      "hint": "每答對一個得 1 分，共 3 分"
    },
    {
      "title": "6. 語言 (命名)",
      "maxScore": 2,
      "description": "拿出「手錶」和「原子筆」，分別問個案這是什麼？",
      "hint": "每答對一個得 1 分，共 2 分"
    },
    {
      "title": "7. 語言 (複誦)",
      "maxScore": 1,
      "description": "請個案跟著唸一遍：\n「白紙真正寫黑字」或「有錢能使鬼推磨」。",
      "hint": "唸對得 1 分"
    },
    {
      "title": "8. 語言 (口語理解)",
      "maxScore": 3,
      "description": "給個案一張白紙，發出指令(一次講完)：\n「用你的右手拿紙，將紙對摺，然後放在大腿上(或地上)」。",
      "hint": "每做對一個動作得 1 分，共 3 分"
    },
    {
      "title": "9. 語言 (閱讀理解)",
      "maxScore": 1,
      "description": "出示寫有「閉上眼睛」的紙卡。\n請個案讀出來，並照著做。",
      "hint": "個案能閉上眼睛得 1 分"
    },
    {
      "title": "10. 語言 (書寫造句)",
      "maxScore": 1,
      "description": "請個案在紙上寫一個完整的句子。\n(需包含主詞與動詞，且有意義)",
      "hint": "寫出完整句子得 1 分"
    },
    {
      "title": "11. 建構力 (繪圖)",
      "maxScore": 1,
      "description": "請個案照著樣子畫出圖形：\n(兩個交疊的五角形，交疊處需形成一個四邊形)",
      "hint": "圖形正確得 1 分"
    },
  ];//MMSE題目

  late List<int> currentScores;

  @override
  void initState() {
    super.initState();
    // 初始化分數列表，預設都是 0 分
    currentScores = List.filled(questions.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MMSE 簡易心智量表", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("請依據指導語進行測驗，並記錄得分", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Divider(thickness: 2),

          ...List.generate(questions.length, (index) {
            var q = questions[index];
            int max = q['maxScore'];

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 標題與最高分
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(q['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        Text("滿分: $max 分", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 題目敘述 (背景色塊強調)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q['description'],
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 分數選擇器
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            q['hint'],
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text("得分：", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: currentScores[index],
                          elevation: 16,
                          style: const TextStyle(color: Colors.blue, fontSize: 18),
                          underline: Container(
                            height: 2,
                            color: Colors.blueAccent,
                          ),
                          onChanged: (int? newValue) {
                            setState(() {
                              currentScores[index] = newValue!;
                            });
                          },
                          items: List.generate(max + 1, (i) {
                            return DropdownMenuItem<int>(
                              value: i,
                              child: Text("$i"),
                            );
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("分", style: TextStyle(fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 顯示目前總分
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("目前總分：", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                    "${currentScores.reduce((a, b) => a + b)} / 30",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                int total = currentScores.reduce((a, b) => a + b);
                widget.onSaved(total);
                widget.onNext();
              },
              child: const Text("完成 MMSE 評估，下一頁"),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }//MMSE

}


// --- E. Behavioral Problems (行為問題) ---
class BehavioralProblemsForm extends StatefulWidget {
  final Function(int) onSaved;
  final VoidCallback onSubmit;

  const BehavioralProblemsForm({super.key, required this.onSaved, required this.onSubmit});

  @override
  State<BehavioralProblemsForm> createState() => _BehavioralProblemsFormState();
}

class _BehavioralProblemsFormState extends State<BehavioralProblemsForm> {
  final List<String> options = [
    "情緒起伏大，容易生氣或焦躁",
    "出現焦慮、憂鬱或冷漠的情況",
    "社交行為明顯減少或退縮",
    "有不尋常或不適當的行為表現"
  ];//Behavioral Problems題目

  List<bool> checks = [false, false, false, false];
  bool noneOfAbove = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("BehavioralProblems 行為問題問卷",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("在最近一個月內，您是否曾出現以下行為或情緒方面的變化？", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 10),
          ...List.generate(options.length, (index) {
            return CheckboxListTile(
              title: Text(options[index]),
              value: checks[index],
              onChanged: (val) {
                setState(() {
                  checks[index] = val!;
                  if (val) noneOfAbove = false;
                });
              },
            );
          }),
          CheckboxListTile(
            title: const Text("以上皆無"),
            value: noneOfAbove,
            onChanged: (val) {
              setState(() {
                noneOfAbove = val!;
                if (val) checks = [false, false, false, false];
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                // 計分邏輯: 若勾選任一項(前4項) -> 1，以上皆無 -> 0
                int score = checks.contains(true) ? 1 : 0;
                widget.onSaved(score);
                widget.onSubmit(); // 這是最後一份，觸發送出
              },
              child: const Text("送出評估結果", style: TextStyle(color: Colors.white)),

            ),

          )
        ],
      ),
    );
  }//Behavioral Problems

}


// --- F. Functional Assessment (整體功能評分) ---
class FunctionalAssessmentForm extends StatefulWidget {
  final Function(int) onSaved;
  final VoidCallback onSubmit; // 這是最後一關，所以用 Submit

  const FunctionalAssessmentForm({super.key, required this.onSaved, required this.onSubmit});

  @override
  State<FunctionalAssessmentForm> createState() => _FunctionalAssessmentFormState();
}

class _FunctionalAssessmentFormState extends State<FunctionalAssessmentForm> {
  // 預設 10 分
  double _currentValue = 10;

  final Map<int, String> _descriptions = {
    10: "功能完全正常，生活與社交無限制 (正常老化)",
    9: "極輕微功能下降，僅在複雜活動出現困難 (非常早期)",
    8: "輕度功能障礙，IADL 有明顯退化 (輕度 AD)",
    7: "需提醒才能完成部分日常活動",
    6: "IADL 大多需協助，基本 ADL 尚可",
    5: "基本 ADL 開始受影響，需部分協助",
    4: "多數日常活動需他人協助",
    3: "嚴重功能障礙，僅能完成簡單活動",
    2: "幾乎完全依賴照顧者",
    1: "極重度功能障礙，無法自理生活",
    0: "極重度功能障礙，無法自理生活", // 0 與 1 共用描述
  };//function題目

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Functional Assessment 整體功能評分", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("請拖動滑桿，選擇最符合個案目前的整體功能狀態：", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Divider(),
          const SizedBox(height: 20),

          // 顯示目前分數與描述
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200)
            ),
            child: Column(
              children: [
                Text(
                  "${_currentValue.toInt()} 分",
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  _descriptions[_currentValue.toInt()] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 滑動條 (Slider)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10.0,
              activeTrackColor: Colors.blueAccent,
              inactiveTrackColor: Colors.blue.shade100,
              thumbColor: Colors.blue,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
              overlayColor: Colors.blue.withAlpha(32),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: _currentValue,
              min: 0,
              max: 10,
              divisions: 10, // 切成 10 格
              label: _currentValue.toInt().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentValue = value;
                });
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0分 (極重度)", style: TextStyle(color: Colors.grey)),
                Text("10分 (正常)", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // 送出按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // 綠色代表最後送出
                  padding: const EdgeInsets.symmetric(vertical: 15)
              ),
              onPressed: () {
                widget.onSaved(_currentValue.toInt());
                widget.onSubmit(); // 觸發送出結果
              },
              child: const Text(
                  "送出評估結果",
                  style: TextStyle(color: Colors.white, fontSize: 18)
              ),
            ),
          )
        ],
      ),
    );
  }//function

}