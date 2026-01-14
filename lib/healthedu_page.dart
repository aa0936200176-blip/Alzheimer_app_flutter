import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
// 2. 模擬文章資料
// ------------------------------------
final List<HealthArticle> allArticles = [
  HealthArticle(
    category: '飲食',
    title: '阿茲海默症患者的健康飲食指南',
    content: '適當的飲食可以幫助維持認知功能，推薦採用地中海飲食或 MIND 飲食法。多攝取 Omega-3 脂肪酸，例如鮭魚。',
  ),
  HealthArticle(
    category: '飲食',
    title: '避免高糖分與加工食品',
    content: '高糖分攝取已被證實與認知衰退有關，應盡量減少甜點、含糖飲料和高度加工食品的攝取。',
  ),
  HealthArticle(
    category: '用藥',
    title: '認識常用藥物：膽鹼酯酶抑制劑',
    content: '這是阿茲海默症輕中度患者常用的藥物，如多奈哌齊 (Donepezil)，主要作用是增加腦部神經傳導物質，幫助改善記憶。',
  ),
  HealthArticle(
    category: '日常照護',
    title: '建立規律的作息與環境安全',
    content: '固定時間起床與睡覺，保持環境光線充足並移除家中絆倒的潛在風險，如地毯或雜物，減少意外發生。',
  ),
  HealthArticle(
    category: '疾病科普',
    title: '阿茲海默症與失智症的區別',
    content: '失智症 (Dementia) 是一個總稱，指認知功能下降影響日常生活。阿茲海默症 (Alzheimer\'s Disease) 是最常見的失智症類型。',
  ),
  HealthArticle(
    category: '常見問題',
    title: '如果患者拒絕服藥怎麼辦？',
    content: '應保持冷靜，不要強迫。可以嘗試將服藥融入日常活動中，或諮詢醫師是否能將藥物混入食物中。',
  ),
];
// ------------------------------------
// 4. 主畫面：包含側邊欄和內容區
// ------------------------------------
class AlzheimerEduScreen extends StatefulWidget {
  const AlzheimerEduScreen({super.key});

  @override
  State<AlzheimerEduScreen> createState() => _AlzheimerEduScreenState();
}

class _AlzheimerEduScreenState extends State<AlzheimerEduScreen> {
  // 定義所有分類
  final List<String> categories = ['飲食', '用藥', '日常照護', '疾病科普', '常見問題'];

  // 目前選中的分類索引
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 根據選中索引獲取當前分類名稱
    final currentCategory = categories[_selectedIndex];

    // 篩選出目前分類下的文章
    final filteredArticles = allArticles
        .where((article) => article.category == currentCategory)
        .toList();

    return Scaffold(

      // 使用 Row 來實現側邊欄和內容的並列佈局
      body: Row(
        children: <Widget>[
          // A. 側邊導航欄 (NavigationRail)
          NavigationRail(
            selectedIndex: _selectedIndex,
            groupAlignment: -1.0, // 頂部對齊
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: categories.map((category) {
              return NavigationRailDestination(
                icon: const Icon(Icons.info_outline),
                selectedIcon: const Icon(Icons.info),
                label: Text(category),
              );
            }).toList(),
          ),

          const VerticalDivider(thickness: 1, width: 1), // 分隔線

          // B. 內容區 (文章列表)
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
// 5. 文章列表元件 (ArticleList)
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
        // 當前分類標題
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity, // ⭐ 讓整行都變色（重點）
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8), // 可要可不要
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


        // 文章列表 (像新聞一樣)
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
                    article.content.split(' ').take(10).join(' ') + '...', // 顯示前十個字作為摘要
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // 導航到文章詳情頁
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(article: article),
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

// 文章詳情頁面
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
          children: <Widget>[
            // 文章標題
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 30, thickness: 2),

            // 文章內容
            Text(
              article.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 40),

            // 提示資訊
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
                  Flexible(child: Text('此資訊僅供衛教參考，具體醫療問題請諮詢專業醫師。')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}