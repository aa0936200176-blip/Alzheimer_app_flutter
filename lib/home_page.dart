import 'package:flutter/material.dart';
import 'dart:async'; // 因為使用了 Timer
import 'dart:math';// 因為使用了Random()
import 'dart:ui' as ui;//拼圖遊戲
import 'package:flutter/services.dart';//拼圖遊戲


// =======================
// 翻牌遊戲
// =======================
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


// =======================
// 看字選色遊戲
// =======================
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


// =======================
// 拼圖遊戲
// =======================
class PuzzleGamePage extends StatefulWidget {
  const PuzzleGamePage({super.key});

  @override
  State<PuzzleGamePage> createState() => _PuzzleGamePageState();
}

class _PuzzleGamePageState extends State<PuzzleGamePage> {
  int level = 1;
  int gridSize = 3; // 起始為 3x3
  bool isLoading = true;

  // 核心數據結構：currentBoardState 存儲目前網格上每個位置放的是哪一號拼圖
  // 例如：currentBoardState[0] = 5 表示第 0 格放著第 5 號拼圖
  late List<int> currentBoardState;

  late List<ui.Image> pieces; // 切割好的圖片碎片
  ui.Image? fullImage;

  final List<String> imagePaths = [
    "assets/image/animal1.jpeg",
    "assets/image/animal2.jpeg",
    "assets/image/animal3.jpg",
    "assets/image/animal4.jpg",
    "assets/image/animal5.jpg",
    "assets/image/animal6.png",
    "assets/image/animal7.jpg",
    "assets/image/animal8.jpg",
    "assets/image/animal9.jpg",
    "assets/image/animal10.jpg"
  ];//圖片

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  Future<void> _startLevel() async {
    // 隨著等級增加難度 (3x3 -> 4x4 -> 5x5...)
    gridSize = 2 + (level / 2).ceil();
    if (gridSize < 3) gridSize = 3; // 最小 3x3
    if(gridSize > 6) gridSize = 6;//限制最大只能到 6x6

    int totalPieces = gridSize * gridSize;

    try {
      // 計算要用哪張圖 (使用取餘數 % 運算，讓圖片可以循環使用)
      int imageIndex = (level - 1) % imagePaths.length;
      String currentAsset = imagePaths[imageIndex];

      final data = await rootBundle.load(currentAsset);// 載入選定的圖片

      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      ui.Image loadedImage = frame.image;
      fullImage = loadedImage;

      // 切割圖片
      pieces = await _splitImage(loadedImage, gridSize);

      // 初始化拼圖位置
      // 1. 產生正確的順序 [0, 1, 2, 3...]
      currentBoardState = List.generate(totalPieces, (index) => index);

      // 2. 打亂順序 (確保不會一開始就是贏的)
      do {
        currentBoardState.shuffle();
      } while (_isSolved()); // 如果剛好隨機成正確答案，就重洗

    } catch (e) {
      print("Error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }//切割圖片


  Future<List<ui.Image>> _splitImage(ui.Image image, int grid) async {
    int minSize = min(image.width, image.height);// 取最短邊，確保切出來是正方形
    int pieceSize = (minSize / grid).floor();
    List<ui.Image> output = [];

    int offsetX = (image.width - minSize) ~/ 2;// 算出 X 偏移量 (置中)
    int offsetY = (image.height - minSize) ~/ 2;// 算出 Y 偏移量 (置中)

    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        // 裁切
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

        final piece = await recorder.endRecording().toImage(pieceSize, pieceSize);
        output.add(piece);
      }
    }
    return output;
  }// 切割圖片邏輯


  void _swapPieces(int sourceIndex, int targetIndex) {
    setState(() {
      // 交換兩個位置的數值
      final temp = currentBoardState[sourceIndex];
      currentBoardState[sourceIndex] = currentBoardState[targetIndex];
      currentBoardState[targetIndex] = temp;
    });

    if (_isSolved()) {
      _showWinDialog();
    }
  }// 處理交換邏輯


  bool _isSolved() {
    for (int i = 0; i < currentBoardState.length; i++) {
      if (currentBoardState[i] != i) return false;
    }
    return true;
  }// 檢查是否完成

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Level Completed! 🎉"),
        content: const Text("Great job! Ready for the next challenge?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                level++;
                isLoading = true;
              });
              _startLevel();
            },
            child: const Text("Next Level"),
          ),
        ],
      ),
    );
  }//過關訊息


  @override
  Widget build(BuildContext context) {

    String currentImgPath = "";
    if (imagePaths.isNotEmpty) {
      currentImgPath = imagePaths[(level - 1) % imagePaths.length];
    }// 避免除以零或索引錯誤

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Level $level", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF003366)],
          ),
        ),
        // 1. 確保整個遊戲區塊在螢幕正中央
        alignment: Alignment.center,

        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
          // SafeArea 確保內容不會被手機瀏海或底部橫條擋住
          child: Column(
            children: [
              // --- 上半部：拼圖遊戲區 ---
              Expanded(
                flex: 4, // 權重設為 4，讓拼圖區佔比較大
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 1, // 保持正方形
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(2.0),

                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentBoardState.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridSize,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                            ),
                            itemBuilder: (context, index) {
                              int pieceIndex = currentBoardState[index];
                              return _buildDraggablePiece(index, pieceIndex);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- 下半部：原圖區 ---
              Expanded(
                flex: 1, // 權重設為 1，佔比較小
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "原圖",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100, // 固定高度，避免圖片太大
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // 這裡直接顯示圖片，不需要用切割後的 ui.Image
                      child: currentImgPath.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(currentImgPath, fit: BoxFit.contain),
                      )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // 底部稍微留白
            ],
          ),
        ),
      ),
    );
  }//畫面外觀

  Widget _buildDraggablePiece(int boardIndex, int pieceIndex) {
    // 這是顯示在格子裡的拼圖 Widget
    Widget pieceWidget = Container(
      color: Colors.white, // 避免透明時看到底色
      child: RawImage(
        image: pieces[pieceIndex],
        fit: BoxFit.cover,
      ),
    );

    return DragTarget<int>(
      // 當其他拼圖拖到這個格子上方時
      onWillAcceptWithDetails: (details) => true, // 總是接受交換
      onAcceptWithDetails: (details) {
        // details.data 是「來源格子的 Index」(fromIndex)
        int fromIndex = details.data;
        int toIndex = boardIndex;

        if (fromIndex != toIndex) {
          _swapPieces(fromIndex, toIndex);
        }
      },
      builder: (context, candidateData, rejectedData) {
        // 使用 Draggable 包裹，確保每個位置的拼圖都能被拖曳
        return Draggable<int>(
          data: boardIndex, // 傳遞「我是從哪個格子來的」
          feedback: SizedBox(
            // 拖曳時的樣子 (稍微縮小一點增加手感)
            width: 100,
            height: 100,
            child: Opacity(
              opacity: 0.8,
              child: Material(
                elevation: 4,
                child: pieceWidget,
              ),
            ),
          ),
          childWhenDragging: Container(
            color: Colors.black12, // 拖曳時原地顯示的顏色
          ),
          child: pieceWidget, // 平常顯示的樣子
        );
      },
    );
  }

}//拼圖遊戲