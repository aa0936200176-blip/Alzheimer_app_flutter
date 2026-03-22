import 'package:flutter/material.dart';

// ------------------------------------
// 1. 資料結構 Model
// ------------------------------------
class HealthArticle {
  final String category;
  final String title;
  final String content;

  HealthArticle({
    required this.category,
    required this.title,
    required this.content,
  });
}

// ------------------------------------
// 2. 文章資料
// ------------------------------------
final List<HealthArticle> allArticles = [
  // ===== 飲食 =====
  HealthArticle(
    category: '飲食',
    title: '好預防失智症飲食大公開',
    content: '''
阿茲海默症患者的健康飲食指南：
- 適當的飲食可以幫助維持認知功能，推薦採用地中海飲食或 MIND 飲食法。
- 多攝取 Omega-3 脂肪酸，例如鮭魚。
- 減少甜點、含糖飲料和高度加工食品。
''',
  ),
  HealthArticle(
    category: '飲食',
    title: '預防阿茲海默症 美國醫師建議常吃、少吃和「最好別碰」的食物',
    content: '''
建議：
- 常吃：蔬菜、水果、全穀、魚類
- 少吃：紅肉、加工肉品
- 最好別碰：高糖零食、高鹽食品
''',
  ),
  HealthArticle(
    category: '飲食',
    title: '阿玆海默症 帕金森氏症 失智症 認知功能與飲食營養',
    content: '''
研究指出：
- 適量攝取蛋白質與健康脂肪，有助於維持大腦健康。
- 避免營養不足與血糖劇烈波動。
''',
  ),
  HealthArticle(
    category: '飲食',
    title: '吃飯這件事，我忘了─失智症的飲食行為轉變',
    content: '''
失智症患者可能出現：
- 忘記吃飯
- 偏好特定食物
- 進食時間或地點混亂
照護者需觀察並提供安全便利的飲食環境。
''',
  ),

  // ===== 用藥 =====
  HealthArticle(
    category: '用藥',
    title: '失智症新藥來了！',
    content: '''
介紹最新失智症藥物，主要作用是增加腦部神經傳導物質，幫助改善記憶。
請諮詢醫師後使用，避免自行購買。
''',
  ),
  HealthArticle(
    category: '用藥',
    title: '臺北榮民總醫院失智治療及研究中心-失智症藥物',
    content: '''
說明常用藥物及劑量，提供治療建議及注意事項。
請遵從醫師指示。
''',
  ),
  HealthArticle(
    category: '用藥',
    title: '臺安醫院-淺談阿茲海默失智症的藥物治療',
    content: '''
介紹各類藥物的機制與副作用，幫助病人及家屬了解治療方式。
''',
  ),
  HealthArticle(
    category: '用藥',
    title: '失智症及失智症藥物簡介',
    content: '''
失智症藥物主要分為：
- 胆鹼酯酶抑制劑
- NMDA 受體拮抗劑
依醫師建議使用。
''',
  ),

  // ===== 日常照護 =====
  HealthArticle(
    category: '日常照護',
    title: '失智症照顧技巧',
    content: '''
提供日常照護建議：
- 建立規律作息
- 保持環境安全
- 鼓勵社交互動
''',
  ),
  HealthArticle(
    category: '日常照護',
    title: '失智症之照護',
    content: '''
照護要點：
- 觀察情緒變化
- 提供心理支持
- 適時給予協助
''',
  ),
  HealthArticle(
    category: '日常照護',
    title: '如何延緩阿茲海默氏失智症的發生或惡化',
    content: '''
建議：
- 規律運動
- 心智訓練
- 均衡飲食
''',
  ),
  HealthArticle(
    category: '日常照護',
    title: '失智症的長者適合到日間照顧中心嗎？',
    content: '''
日間照顧中心優點：
- 提供專業照護
- 社交互動
- 認知訓練
''',
  ),

  // ===== 疾病科普 =====
  HealthArticle(
    category: '疾病科普',
    title: '認識失智症',
    content: '''
失智症是認知功能下降影響日常生活的總稱。
阿茲海默症是最常見的失智症類型。
''',
  ),
  HealthArticle(
    category: '疾病科普',
    title: '失智症問題行為',
    content: '''
失智症患者可能出現：
- 暴躁
- 重複言語
- 迷路
家屬需了解行為原因並給予適當協助。
''',
  ),
  HealthArticle(
    category: '疾病科普',
    title: '失智症居家注意事項',
    content: '''
建議：
- 移除家中絆倒物
- 安裝扶手與夜燈
- 確保藥物安全
''',
  ),

  // ===== 常見問題 =====
  HealthArticle(
    category: '常見問題',
    title: '阿茲海默症10大警訊',
    content: '''
注意以下警訊：
1. 記憶力減退
2. 語言表達困難
3. 時間空間感混亂
4. 情緒變化大
5. 日常生活功能下降
6-10. 其他細節請參考專業醫師建議
''',
  ),
  HealthArticle(
    category: '常見問題',
    title: '什麼是失智症？常見失智症症狀、類型、惡化速度與診斷全解析',
    content: '''
失智症包括阿茲海默症、血管性失智等
症狀：記憶、認知、情緒變化
診斷：醫師評估 + 影像學 + 認知測驗
''',
  ),
  HealthArticle(
    category: '常見問題',
    title: '83歲阿嬤施打全台首款失智針',
    content: '''
新藥費用高且有限制，需要醫師評估適合性。
''',
  ),
  HealthArticle(
    category: '常見問題',
    title: '失智症可活多久？能治療或預防嗎？失智症5大常見問題一次看！',
    content: '''
- 目前尚無根治方法
- 可透過藥物延緩惡化
- 預防重點：飲食、運動、心智訓練
''',
  ),
];

// ------------------------------------
// 3. 主畫面
// ------------------------------------
class AlzheimerEduScreen extends StatefulWidget {
  const AlzheimerEduScreen({super.key});

  @override
  State<AlzheimerEduScreen> createState() => _AlzheimerEduScreenState();
}

class _AlzheimerEduScreenState extends State<AlzheimerEduScreen> {
  final List<String> categories = [
    '飲食',
    '用藥',
    '日常照護',
    '疾病科普',
    '常見問題'
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentCategory = categories[_selectedIndex];
    final filteredArticles =
    allArticles.where((a) => a.category == currentCategory).toList();

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            groupAlignment: -1.0,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: categories
                .map((c) => NavigationRailDestination(
              icon: const Icon(Icons.info_outline),
              selectedIcon: const Icon(Icons.info),
              label: Text(c),
            ))
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: ArticleList(
              category: currentCategory,
              articles: filteredArticles,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------
// 4. 文章列表
// ------------------------------------
class ArticleList extends StatelessWidget {
  final String category;
  final List<HealthArticle> articles;

  const ArticleList({
    super.key,
    required this.category,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                category,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.article),
                  title: Text(article.title),
                  subtitle: Text(
                    article.content.split('\n').take(2).join(' ') + '...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ArticleDetailPage(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ------------------------------------
// 5. 文章詳情頁
// ------------------------------------
class ArticleDetailPage extends StatelessWidget {
  final HealthArticle article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.category),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30, thickness: 2),
            Text(
              article.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Flexible(
                      child: Text(
                          '此資訊僅供衛教參考，具體醫療問題請諮詢專業醫師。')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------
// 6. main
// ------------------------------------
void main() {
  runApp(const MaterialApp(
    home: AlzheimerEduScreen(),
    debugShowCheckedModeBanner: false,
  ));
}