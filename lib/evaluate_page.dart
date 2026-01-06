import 'package:alzheimer_app/main.dart';
import 'package:flutter/material.dart';


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

  @override
  String toString() {
    return 'Memory Complaints(記憶抱怨): $memoryScore\nADL日常生活活動量表: $adlScore\nSleep Quality(睡眠品質): $sleepScore\nMMSE(簡易心智量表): $mmseScore\nBehavioralProblems(行為問題): $behaviorScore';
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
            const Text("請依序回答接下來的 5 份問卷", style: TextStyle(fontSize: 18)),
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
  final int _totalPages = 5;

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

  void _submitResults() {
    // 這裡處理最終送出邏輯 (例如傳送到 API)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("評估完成"),
        content: Text("您的評估結果如下：\n\n${_result.toString()}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog

              Navigator.pop(context);
            },
            child: const Text("回評估首頁"),
          )
        ],
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
  // 這裡建立了詳細的題目資料結構，包含每個分數對應的描述
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
        {"score": 0, "text": "完全依賴。"}
      ]
    },
    {
      "title": "6. 排尿控制",
      "options": [
        {"score": 10, "text": "日夜皆不會尿失禁，或可自行處理尿套/尿布。"},
        {"score": 5, "text": "偶爾會尿失禁(每週不超過一次)或尿急(無法等待便盆或無法及時趕到廁所)或需別人幫忙處理尿套。"},
        {"score": 0, "text": "完全依賴。"}
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

  final Map<String, int> maxScores = {
    "定向感 (時間)": 5, //
    "定向感 (地方)": 5, //
    "注意力 (訊息登錄)": 3, //
    "注意力 (計算/減七)": 5, //
    "記憶力 (回憶)": 3, //
    "語言 (命名)": 2, //
    "語言 (複誦)": 1, //
    "語言 (理解)": 3, // [cite: 27]
    "語言 (閱讀)": 1, // [cite: 27]
    "語言 (書寫)": 1, // [cite: 27]
    "建構力 (繪圖)": 1, // [cite: 27]
  };//MMSE題目

  late Map<String, int> currentScores;

  @override
  void initState() {
    super.initState();
    currentScores = {for (var k in maxScores.keys) k: 0};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MMSE 簡易心智量表", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("請輸入各測驗項目的得分", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Divider(),
          ...maxScores.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 16))),
                  DropdownButton<int>(
                    value: currentScores[entry.key],
                    items: List.generate(entry.value + 1, (i) {
                      return DropdownMenuItem(value: i, child: Text("$i 分"));
                    }),
                    onChanged: (val) {
                      setState(() {
                        currentScores[entry.key] = val!;
                      });
                    },
                  ),
                  Text("/ ${entry.value} 分")
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                int total = currentScores.values.reduce((a, b) => a + b);
                widget.onSaved(total);
                widget.onNext();
              },
              child: const Text("完成MMSE評估 下一頁"),
            ),
          )
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