import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api.dart';

class GameReviewPage extends StatefulWidget {

  final String account;

  const GameReviewPage({
    super.key,
    required this.account,
  });
  @override
  State<GameReviewPage> createState() => _GameReviewPageState();
}


class _GameReviewPageState extends State<GameReviewPage> {
  final ApiService _api = ApiService(useMock: false); // 改成 false 時連真實後端
  bool isLoading = true;

  List<Map<String, dynamic>> flipHistory = [];   // 翻牌：{'seconds': 時間, 'playedAt': '日期'}
  List<Map<String, dynamic>> colorHistory = [];  // 看字：{'score': 題數, 'playedAt': '日期'}
  List<Map<String, dynamic>> puzzleHistory = []; // 拼圖：{'level': 關卡, 'playedAt': '日期'}

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);

    try {
      flipHistory = await _api.getGameHistory(widget.account, 'flip');
      colorHistory = await _api.getGameHistory(widget.account, 'color');
      puzzleHistory = await _api.getGameHistory(widget.account, 'puzzle');


      // 排序：按時間由舊到新（方便折線圖）
      flipHistory.sort((a, b) => DateTime.parse(a['playedAt']).compareTo(DateTime.parse(b['playedAt'])));
      colorHistory.sort((a, b) => DateTime.parse(a['playedAt']).compareTo(DateTime.parse(b['playedAt'])));
      puzzleHistory.sort((a, b) => DateTime.parse(a['playedAt']).compareTo(DateTime.parse(b['playedAt'])));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入失敗：$e'), backgroundColor: Colors.red),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildTrendChart({
    required String title,
    required List<Map<String, dynamic>> records,
    required String valueKey,
    required Color lineColor,
    required String unit,
    required bool lowerIsBetter, // true: 越低越好（翻牌時間），false: 越高越好
  }) {
    if (records.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$title：尚無紀錄', style: const TextStyle(fontSize: 16)),
        ),
      );
    }

    final spots = records.asMap().entries.map((e) {
      final index = e.key.toDouble();
      //final value = (e.value[valueKey] ?? 0).toDouble();
      final value = (e.value[valueKey] as num?)?.toDouble() ?? 0;
      return FlSpot(index, value);
    }).toList();
    if (spots.length == 1) {
      spots.add(FlSpot(spots.first.x + 1, spots.first.y));
    }
    if (spots.length == 1) {
      spots.add(FlSpot(spots.first.x + 1, spots.first.y));
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  lowerIsBetter ? '越低越好' : '越高越好',
                  style: TextStyle(
                    color: lowerIsBetter ? Colors.green : Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  //maxX: (records.length - 1).toDouble(),
                  maxX: records.length <= 1 ? 1 : (records.length - 1).toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('單位：$unit', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('遊戲回顧'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrendChart(
                title: '翻牌遊戲 - 完成時間趨勢',
                records: flipHistory,
                valueKey: 'seconds',
                lineColor: Colors.blue,
                unit: '秒',
                lowerIsBetter: true,
              ),
              const SizedBox(height: 24),
              _buildTrendChart(
                title: '看字選色 - 答對題數趨勢',
                records: colorHistory,
                valueKey: 'score',
                lineColor: Colors.green,
                unit: '題',
                lowerIsBetter: false,
              ),
              const SizedBox(height: 24),
              _buildTrendChart(
                title: '拼圖遊戲 - 完成關卡趨勢',
                records: puzzleHistory,
                valueKey: 'level',
                lineColor: Colors.orange,
                unit: '關卡',
                lowerIsBetter: false,
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  '資料來自後端 API，登入後可查看個人紀錄',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHistory,
        tooltip: '重新載入',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}