import 'package:flutter/material.dart';
import 'dart:async'; // 因為使用了 Timer
import 'dart:math';// 因為使用了Random()
import 'dart:ui' as ui;//拼圖遊戲
import 'package:flutter/services.dart';//拼圖遊戲


class GameLevelPage extends StatefulWidget {
  const GameLevelPage({super.key});

  @override
  State<GameLevelPage> createState() => _GameLevelPageState();
}

class _GameLevelPageState extends State<GameLevelPage> {
  int level = 1; // 關卡數
  int seconds = 0;//遊戲計時
  Timer? timer;

  late List<String> images;// 存放卡片圖片路徑
  late List<bool> flipped;// 記錄每張卡片是否翻開
  late List<bool> matched;// 記錄每張卡片是否已配對成功
  int? firstIndex;// 第一張被翻開的卡片索引
  bool isChecking = false; // 防止在比對時點第三張

  final List<int> cardCounts = [4, 4, 6, 6, 8, 8, 10];// 每一關的卡片數

  @override
  void initState() {
    super.initState();
    _startLevel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });//啟動 Timer，每秒數字 +1
    });
  }


  void _startLevel() {
    int cardCount = cardCounts[level - 1];

    List<String> baseImages = [
      "assets/image/1.png",
      "assets/image/2.png",
      "assets/image/3.png",
      "assets/image/4.png",
      "assets/image/5.png",
      "assets/image/1.png",
      "assets/image/2.png",
      "assets/image/3.png",
      "assets/image/4.png",
      "assets/image/5.png",
    ];

    int pairCount = cardCount ~/ 2;
    images = [];
    for (int i = 0; i < pairCount; i++) {
      images.add(baseImages[i]);
      images.add(baseImages[i]);
    }//從 baseImages 取需要的圖片，成對加入 images

    images.shuffle(Random());//shuffle()打亂順序

    flipped = List.generate(cardCount, (_) => false);
    matched = List.generate(cardCount, (_) => false);//初始化 flipped、matched
    firstIndex = null;
    isChecking = false;
  }//開始新關卡


  void _flipCard(int index) {
    if (matched[index] || flipped[index] || isChecking) return;
    //matched:匹配的，flipped:翻轉

    setState(() {
      flipped[index] = true;
    });

    if (firstIndex == null) {
      firstIndex = index;
    } else {
      isChecking = true; // ✅ 鎖定
      if (images[firstIndex!] == images[index]) {
        // ✅ 配對成功
        setState(() {
          matched[firstIndex!] = true;
          matched[index] = true;
        });
        firstIndex = null;
        isChecking = false;

        if (matched.every((e) => e)) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (level < cardCounts.length) {
              setState(() {
                level++;
                _startLevel();
              });
            } else {
              timer?.cancel();
              _showFinalDialog();
            }
          });
        }
      } else {
        // ❌ 失敗 → 兩張牌都保持翻開 1 秒再一起蓋回去
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            flipped[firstIndex!] = false;
            flipped[index] = false;
          });
          firstIndex = null;
          isChecking = false;
        });
      }
    }
  }//翻牌邏輯


  void _showFinalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("遊戲完成 🎉"),
        content: Text("總花費時間：$seconds 秒"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level = 1;
                seconds = 0;
                _startLevel();
                timer = Timer.periodic(const Duration(seconds: 1), (_) {
                  setState(() {
                    seconds++;
                  });
                });
              });
            },
            child: const Text("再玩一次"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("回主選單"),
          ),
        ],
      ),
    );
  }//遊戲結束

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("第 $level 關"),
        actions: [
          Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("⏱ $seconds 秒"),
              )),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          int columns = 2; // 每列 2 張
          int rows = (images.length / columns).ceil(); // 計算行數

          double crossAxisSpacing = 10;
          double mainAxisSpacing = 10;
          double padding = 20;

          // 計算每張卡片最大寬高
          double cardWidth = (screenWidth - padding * 2 - crossAxisSpacing * (columns - 1)) / columns;
          double cardHeight = (screenHeight - padding * 2 - mainAxisSpacing * (rows - 1)) / rows;

          double cardSize = cardWidth < cardHeight ? cardWidth : cardHeight; // 取最小值

          return Center(
            child: SizedBox(
              width: (cardSize * columns) + (crossAxisSpacing * (columns - 1)),
              height: (cardSize * rows) + (mainAxisSpacing * (rows - 1)),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // 禁止滾動
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: 1.0, // 正方形
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _flipCard(index),
                    child: Container(
                      width: cardSize,
                      height: cardSize,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: flipped[index] || matched[index]
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(images[index], fit: BoxFit.cover),
                      )
                          : const Center(
                        child: Text(
                          "?",
                          style: TextStyle(fontSize: 36, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }//介面
}//翻牌遊戲


class Game2Page extends StatefulWidget {
  const Game2Page({super.key});
  @override
  _Game2PageState createState() => _Game2PageState();
}

class _Game2PageState extends State<Game2Page> {
  final List<Map<String, dynamic>> colors = [
    {"name": "紅", "color": Colors.red},
    {"name": "藍", "color": Colors.blue},
    {"name": "綠", "color": Colors.green},
    {"name": "紫", "color": Colors.purple},
    {"name": "橘", "color": Colors.orange},
  ];

  int score = 0;
  String displayWord = "";
  Color displayColor = Colors.black;
  Color correctColor = Colors.black;

  List<Widget> options = [];
  Color? borderColor1;
  Color? borderColor2;

  // --- 計時器相關變數 ---
  Timer? _timer; // 總倒數計時器
  Timer? _roundTimer; // 每 2 秒換題計時器
  int _timeLeft = 30; // 總遊戲剩餘時間
  bool _isGameOver = false; // 遊戲是否結束
  // --------------------------

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    // 必須取消所有計時器以避免記憶體洩漏
    _timer?.cancel();
    _roundTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      score = 0;
      _timeLeft = 30;
      _isGameOver = false;
    });

    // 1. 總倒數計時器 (每秒更新)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        // 時間到，遊戲結束
        _timer?.cancel();
        _roundTimer?.cancel();
        _isGameOver = true;
        showGameOverDialog();
      }
    });

    // 2. 每 2 秒換題計時器 (定期換題)
    _roundTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isGameOver) {
        nextRound();
      } else {
        _roundTimer?.cancel();
      }
    });

    // 立即開始第一輪
    nextRound();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("時間到 ⌛"),
        content: Text("遊戲結束！\n你的分數：$score 題"),
        actions: [
          TextButton(
            child: const Text("再玩一次"),
            onPressed: () {
              Navigator.pop(context);
              startGame(); // 重新開始遊戲
            },
          ),
          TextButton(
            child: const Text("離開"),
            //onPressed: () => Navigator.pop(context),
            onPressed: () {
              // 1. 關閉當前的對話框 (AlertDialog)
              Navigator.pop(context);

              // 2. 關閉 Game2Page 畫面，回到上一個畫面 (主畫面)
              //
              // 程式碼中看到的按鈕點擊動作只有一次，
              // 但它觸發了兩個 pop 指令，這是正確的。
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void nextRound() {
    if (_isGameOver) return;

    final rnd = Random();
    final textItem = colors[rnd.nextInt(colors.length)];
    final colorItem = colors[rnd.nextInt(colors.length)];

    displayWord = textItem["name"];
    displayColor = colorItem["color"];
    correctColor = textItem["color"]; // 正確答案：內容意義的顏色 (e.g. 字是紅，顏色就是紅)

    // 錯誤答案：預設為字體的顏色 (e.g. 字體是藍，顏色就是藍)
    Color wrongColor = displayColor;

    // **********************************************
    // 關鍵修改：處理顏色衝突
    // **********************************************
    // 判斷：如果 內容意義的顏色 (correctColor) 等於 字體的顏色 (wrongColor/displayColor)，
    // 則需要從列表中重新選取一個顏色作為錯誤答案，並確保它不等於 correctColor
    if (correctColor == wrongColor) {

      // 過濾掉正確顏色，從剩餘的顏色中隨機選取一個作為新的錯誤顏色
      final List<Color> uniqueWrongColors = colors
          .map((c) => c["color"] as Color)
          .where((c) => c != correctColor)
          .toList();

      if (uniqueWrongColors.isNotEmpty) {
        // 從不衝突的顏色中隨機選一個
        wrongColor = uniqueWrongColors[rnd.nextInt(uniqueWrongColors.length)];
      } else {
        // 這是極端情況 (所有顏色都相同)，但為避免程式碼崩潰，仍保留原樣
      }
    }
    // **********************************************

    borderColor1 = null;
    borderColor2 = null;

    // 隨機決定正確答案和錯誤答案的按鈕位置
    final bool isOption1Correct = rnd.nextBool();

    // 按鈕 1 (選項一)
    Widget option1 = ElevatedButton(
      style: ElevatedButton.styleFrom(
        // 設定背景顏色
        backgroundColor: isOption1Correct ? correctColor : wrongColor,
        fixedSize: const Size(200, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: borderColor1 ?? Colors.transparent, width: 4),
        ),
      ),
      // 傳遞按鈕的實際顏色，用於 checkAnswer 檢查
      onPressed: () => checkAnswer(isOption1Correct ? correctColor : wrongColor, 1),
      child: const SizedBox.shrink(),
    );

    // 按鈕 2 (選項二)
    Widget option2 = ElevatedButton(
      style: ElevatedButton.styleFrom(
        // 設定背景顏色
        backgroundColor: isOption1Correct ? wrongColor : correctColor,
        fixedSize: const Size(200, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: borderColor2 ?? Colors.transparent, width: 4),
        ),
      ),
      // 傳遞按鈕的實際顏色，用於 checkAnswer 檢查
      onPressed: () => checkAnswer(isOption1Correct ? wrongColor : correctColor, 2),
      child: const SizedBox.shrink(),
    );

    options = [option1, option2]..shuffle(); // 再次打亂選項位置，讓遊戲更有挑戰性

    setState(() {});
  }

  void checkAnswer(Color choice, int optionIndex) {
    if (_isGameOver) return;

    // 答題後，不論對錯，都重置 2 秒換題計時器
    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isGameOver) {
        nextRound();
      } else {
        _roundTimer?.cancel();
      }
    });

    if (choice == correctColor) {
      setState(() {
        score++;
      });
      // 答對，立即進入下一題
      nextRound();
    } else {
      // 答錯 → 對應按鈕閃紅
      setState(() {
        // 答錯時，根據按下的選項索引來設定對應的邊框顏色
        if (optionIndex == 1) borderColor1 = Colors.red;
        if (optionIndex == 2) borderColor2 = Colors.red;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isGameOver) {
          nextRound();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Game 2 - 看字選顏色"),
        backgroundColor: Colors.black87,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "剩餘時間：$_timeLeft 秒",
              style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "已答對：$score 題",
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(height: 40),
            Text(
              displayWord,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: displayColor,
              ),
            ),
            const SizedBox(height: 50),
            Column(
              children: options.map((option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: option,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}//看字選色遊戲


class PuzzleGamePage extends StatefulWidget {
  const PuzzleGamePage({super.key});

  @override
  State<PuzzleGamePage> createState() => _PuzzleGamePageState();
}

class _PuzzleGamePageState extends State<PuzzleGamePage> {
  int level = 1; // 關卡數
  int seconds = 0;
  Timer? timer;

  late List<int?> placedPieces; // 拼圖板上的拼圖 (pieceValue), null = 空格
  late List<int> trayPieces;    // 尚未放到拼圖板上的拼圖 (pieceValue)

  ui.Image? fullImage; // 完整的圖片用於提示圖

  late List<int> correct; // 正確拼圖順序 (pieceValue == index)
  late int gridSize; // 每關的拼圖大小，例如 2x2、3x3
  late List<ui.Image> pieces; // 真正裁好的拼圖片
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLevel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
  }

  Future<void> _startLevel() async {
    gridSize = min(2 + level, 4);// 讓 gridSize 依 level 增加，但最多到 4x4
    int totalPieces = gridSize * gridSize;
    ui.Image? loadedImage;

    // 載入圖片並裁切
    try {
      final data = await rootBundle.load("assets/puzzle.jpg");
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      loadedImage = frame.image; // 載入完整的圖片

      pieces = await _splitImage(loadedImage, gridSize);

      // 儲存完整的圖片用於提示圖
      fullImage = loadedImage;

    } catch (e) {
      print("Error loading or splitting image: $e");
      return;
    }

    correct = List.generate(totalPieces, (i) => i);

    placedPieces = List.filled(totalPieces, null);
    trayPieces = List.generate(totalPieces, (i) => i)..shuffle();

    setState(() {
      isLoading = false;
    });
  }

  //切割圖片成 NxN (保持原方法)
  Future<List<ui.Image>> _splitImage(ui.Image image, int grid) async {
    // 保持圖片為正方形
    int minSize = min(image.width, image.height);

    int pieceSize = (minSize / grid).floor();
    List<ui.Image> output = [];

    // 計算圖片中心點，以便從中間裁切正方形
    int offsetX = (image.width - minSize) ~/ 2;
    int offsetY = (image.height - minSize) ~/ 2;

    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(
            offsetX + x * pieceSize.toDouble(),
            offsetY + y * pieceSize.toDouble(),
            pieceSize.toDouble(),
            pieceSize.toDouble(),
          ),
          Rect.fromLTWH(0, 0, pieceSize.toDouble(), pieceSize.toDouble()),
          Paint(),
        );

        final piece =
        await recorder.endRecording().toImage(pieceSize, pieceSize);
        output.add(piece);
      }
    }
    return output;
  }

  void _handlePieceDrop(int pieceValue, int targetIndex) {
    setState(() {
      // 1. 如果目標位置已經有拼圖，則將該拼圖退回托盤
      //    (在 Jigsaw 玩法中，如果只允許放到正確位置，這個邏輯可以簡化)
      if (placedPieces[targetIndex] != null) {
        trayPieces.add(placedPieces[targetIndex]!);
      }

      // 2. 將拖曳進來的拼圖從托盤中移除
      trayPieces.remove(pieceValue);

      // 3. 將新的拼圖放到目標位置
      placedPieces[targetIndex] = pieceValue;
    });

    _checkWinCondition();
  }

  void _checkWinCondition() {
    bool isWin = true;
    for (int i = 0; i < placedPieces.length; i++) {
      // 判斷該位置上的拼圖是否就是正確的拼圖 (pieceValue == index)
      if (placedPieces[i] != i) {
        isWin = false;
        break;
      }
    }

    if (isWin) {
      _nextLevel();
    }
  }

  void _nextLevel() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (level < 3) {//關卡數
        setState(() {
          level++;
          isLoading = true;
        });
        _startLevel();
      } else {
        timer?.cancel();
        _showFinalDialog();
      }
    });
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("遊戲完成 🎉"),
        content: Text("總花費時間：$seconds 秒"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level = 1;
                seconds = 0;
                isLoading = true;
              });
              _startLevel();
              timer = Timer.periodic(const Duration(seconds: 1), (_) {
                setState(() {
                  seconds++;
                });
              });
            },
            child: const Text("再玩一次"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("回主選單"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("第 $level 關 ( ${gridSize}x$gridSize )"),
        actions: [
          Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("⏱ $seconds 秒"),
              )),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          // 計算主板和托盤的尺寸
          // 讓托盤佔用 20% 寬度，主拼圖區佔用 80%
          double mainAreaWidth = constraints.maxWidth * 0.8;

          // 讓主拼圖區的高度可以填滿可用高度 (減去一些邊距)
          double mainAreaHeight = constraints.maxHeight - 32;

          // 計算主拼圖區 (提示圖+拼圖板) 可用的最大正方形邊長
          // 這是為了保持拼圖板的正方形比例
          double maxSide = min(mainAreaWidth, mainAreaHeight);

          // 提示圖佔總高度的 35%，拼圖板佔 65%
          double hintRatio = 0.35;
          double boardRatio = 0.65;

          // 拼圖板的尺寸：取主區域的 maxSide 的 boardRatio
          double boardSide = maxSide * boardRatio;

          // 提示圖的尺寸：取主區域的 maxSide 的 hintRatio
          double hintSide = maxSide * hintRatio;

          double pieceSize = boardSide / gridSize; // 單個拼圖的大小

          return Row(
            children: [
              // 1. 拼圖區 (提示圖 + 拼圖板) - 佔據大部分空間
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // *** 提示圖 (原圖) ***
                      if (fullImage != null)
                        Container(
                          width: hintSide,
                          height: hintSide,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: RawImage(
                            image: fullImage!,
                            fit: BoxFit.cover,
                          ),
                        ),

                      // *** 拼圖板 (Drag Targets) ***
                      Container(
                        width: boardSide,
                        height: boardSide,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent, width: 4),
                          color: Colors.grey[300], // 拼圖底色
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                          ),
                          itemCount: placedPieces.length,
                          itemBuilder: (context, targetIndex) {
                            int? pieceValue = placedPieces[targetIndex];

                            // 每個網格都是一個 DragTarget
                            return DragTarget<int>(
                              onWillAcceptWithDetails: (details) {
                                int draggedPieceValue = details.data;
                                // Jigsaw 邏輯：只允許拖到**正確的**位置
                                return draggedPieceValue == targetIndex;
                              },
                              onAcceptWithDetails: (details) {
                                int draggedPieceValue = details.data;
                                _handlePieceDrop(draggedPieceValue, targetIndex);
                              },
                              builder: (context, candidateData, rejectedData) {
                                // 如果這個位置已經有拼圖了
                                if (pieceValue != null) {
                                  // 顯示已經放好的拼圖
                                  return RawImage(
                                    image: pieces[pieceValue],
                                    fit: BoxFit.cover,
                                  );
                                }

                                // 如果是空白格
                                Color targetColor = candidateData.isNotEmpty
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.transparent;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: targetColor,
                                    // 繪製網格線
                                    border: Border.all(color: Colors.black12, width: 1.0),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. 拼圖托盤 (Draggables)
              Container(
                width: constraints.maxWidth * 0.25, // 托盤佔據右側 25% 寬度
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text("拼圖塊", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: trayPieces.map((pieceValue) {
                            // 托盤中的拼圖大小使用主拼圖板的 pieceSize 來計算，確保一致性
                            double trayPieceSize = pieceSize * 0.9;

                            return Draggable<int>(
                              data: pieceValue,
                              child: Container(
                                width: trayPieceSize,
                                height: trayPieceSize,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                                child: RawImage(
                                  image: pieces[pieceValue],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              feedback: SizedBox(
                                width: pieceSize,
                                height: pieceSize,
                                child: Opacity(
                                  opacity: 0.8,
                                  child: RawImage(
                                    image: pieces[pieceValue],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(
                                width: trayPieceSize,
                                height: trayPieceSize,
                                color: Colors.transparent,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}//拼圖遊戲

extension ListEquality<T> on List<T> {
  bool equals(List<T> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}// 小工具：判斷兩個 List 是否相等(拼圖遊戲)