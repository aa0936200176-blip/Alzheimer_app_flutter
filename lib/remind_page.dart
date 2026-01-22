import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';//匯入日曆套件


class AddEventPage extends StatefulWidget {
  final Function(DateTime, String, Color, String) onSave;

  //為了編輯事件
  final String? initialTitle;//舊的標題
  final String? initialNote;//舊的備註
  final Color? initialColor;//舊的顏色
  final DateTime? initialDate;//舊的日期

  const AddEventPage({
    required this.onSave,
    super.key,
    this.initialTitle,
    this.initialNote,
    this.initialColor,
    this.initialDate,

  });

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _controller = TextEditingController();
  late DateTime _selectedDate;//用late表示稍後在 initState 初始化

  // 下拉式選單用的事件名稱
  String _selectedTitle = '回診';
  List<String> _eventOptions = ['回診', '吃藥', '家族聚會', '運動', '其他'];

  // 顏色選擇器
  Color _selectedColor = Colors.blue;
  final Map<String, Color> _colorOptions = {
    '紅色': Colors.red,
    '橘色': Colors.orange,
    '黃色': Colors.yellow,
    '綠色': Colors.green,
    '藍色': Colors.blue,
    '紫色': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    // 如果有傳入 initialDate (來自日曆點選)，就用它；否則用現在時間
    _selectedDate = widget.initialDate ?? DateTime.now();

    // 事件內容
    if (widget.initialNote != null) {
      _controller.text = widget.initialNote!;
    }

    // 設定顏色
    if (widget.initialColor != null) {
      _selectedColor = widget.initialColor!;
    }

    // 設定標題 (下拉選單)
    if (widget.initialTitle != null) {

      // 確保傳進來的標題確實存在於你的選項清單中
      if (_eventOptions.contains(widget.initialTitle)) {
        _selectedTitle = widget.initialTitle!;
      } else {

        // 如果舊標題不在清單內，預設為 '其他'，或者把這個舊標題臨時加進清單
        _selectedTitle = '其他';
      }
    }
  }//編輯事件設定

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("新增編輯提醒事件")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "請輸入事件內容"),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const Text("選擇日期: "),
                TextButton(
                  child: Text("${_selectedDate.toLocal()}".split(" ")[0]),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),// 日期選擇

            Row(
              children: [
                Text("事件名稱："),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: _selectedTitle,
                  onChanged: (value) {
                    setState(() {
                      _selectedTitle = value!;
                    });
                  },
                  items: _eventOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),// 事件名稱下拉式選單

            SizedBox(height: 16),
            Row(
              children: [
                Text("事件顏色："),
                SizedBox(width: 20),
                DropdownButton<Color>(
                  value: _selectedColor,
                  onChanged: (Color? newColor) {
                    if (newColor != null) {
                      setState(() {
                        _selectedColor = newColor;
                      });
                    }
                  },
                  items: _colorOptions.entries.map((entry) {
                    return DropdownMenuItem<Color>(
                      value: entry.value,
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: entry.value, radius: 8),
                          SizedBox(width: 8),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),// 顏色選擇下拉式選單

            const SizedBox(height: 25),
            ElevatedButton(
              child: const Text(
                "確定",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onPressed: () {
                final note = _controller.text;
                if (_selectedTitle.isNotEmpty) {
                  widget.onSave(_selectedDate, _selectedTitle, _selectedColor, note);
                  Navigator.pop(context); // 返回原畫面
                }
              },
            ),
          ],
        ),
      ),
    );
  }//日曆新增事件頁面

}

class Event {
  final String title;
  final Color color;

  Event({required this.title, required this.color});

  @override
  String toString() => title;
}//日曆加入事件列表與標記顏色點



class RemindPage extends StatefulWidget {
  const RemindPage({super.key});

  @override
  State<RemindPage> createState() => _RemindPage();
}

class _RemindPage extends State<RemindPage>
{
  // 狀態變數
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _selectedEvents = [];


  final Map<DateTime, List<Event>> _events = {
    //DateTime.utc(2025, 5, 6): [Event(title: "考試", color: Colors.green)],
    //DateTime.utc(2025, 5, 14): [Event(title: "聚餐", color: Colors.orange)],
    //DateTime.utc(2025, 5, 20): [Event(title: "演出", color: Colors.blue)],
    //DateTime.utc(2025, 5, 30): [Event(title: "旅行", color: Colors.pink)],
  };//日曆的加入事件

  List<Event> _getEventsForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _events[key] ?? [];
  }//日曆加入事件列表與標記顏色點

  void _deleteEvent(int index) {
    final key = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    setState(() {
      _events[key]!.removeAt(index);
      _selectedEvents = _getEventsForDay(_selectedDay!);
    });
  }//刪除事件

  void _editEvent(int index) {
    final key = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final oldEvent = _events[key]![index];

    // 拆解字串
    List<String> contentParts = oldEvent.title.split("  ");//兩個空白為切割點

    String currentTitle = contentParts[0]; // 前面是標題 (例如: 回診)
    String currentNote = "";               // 預設備註為空

    // 如果長度大於 1，代表後面有備註內容，就把它抓出來
    if (contentParts.length > 1) {
      currentNote = contentParts[1];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(
          // 傳入拆解後的舊資料
          initialDate: _selectedDay,    // 日期
          initialTitle: currentTitle,   // 標題
          initialColor: oldEvent.color, // 顏色
          initialNote: currentNote,     // 備註內容

          onSave: (newDate, newTitle, newColor, newNote) {
            setState(() {
              // 編輯後的儲存邏輯
              _events[key]![index] = Event(title: "$newTitle  $newNote", color: newColor);
              _selectedEvents = _getEventsForDay(_selectedDay!);
            });
          },
        ),
      ),
    );
  }//編輯事件，跳轉至 AddEventPage 並更新資料

  void _addEvent(DateTime date, String title, Color color, String note) {
    final key = DateTime.utc(date.year, date.month, date.day);
    final newEvent = Event(title: "$title" + "  " + "$note", color: color);

    setState(() {
      if (_events.containsKey(key)) {
        _events[key]!.add(newEvent);
      } else {
        _events[key] = [newEvent];
      }

      // 如果目前有選到這天，刷新顯示
      if (isSameDay(_selectedDay, date)) {
        _selectedEvents = _getEventsForDay(date);
      }
    });
  }//日曆新增事件


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(1000, 1, 1),
              lastDay: DateTime.utc(5000, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,

              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),//圓點左右間隔 1.5 px
                          width: 6,
                          height: 6,//圓點大小
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,//做出圓形
                            color: (event as Event).color,//用事件的顏色來顯示圓點
                          ),
                        );
                      }).toList(),
                    );//顯示小圓點
                  }
                  return null;
                },
              ),//日曆上的顯示方式-行程顏色標記
              headerStyle: HeaderStyle(
                formatButtonVisible: true,//日曆格式切換按鈕
                titleCentered: true,//日曆標題是否居中顯示
                formatButtonShowsNext: false,//顯示下一個月的按鈕
                titleTextStyle: TextStyle(fontSize: 20.0),
                leftChevronIcon: Icon(Icons.chevron_left, size: 28),
                rightChevronIcon: Icon(Icons.chevron_right, size: 28),//左右箭頭圖標
                headerPadding: EdgeInsets.symmetric(vertical: 10),//標題區域的內邊距
              ),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedEvents = _getEventsForDay(selectedDay);//日曆事件顯示
                });
              },

            ),
            const SizedBox(height: 20),

            if (_selectedEvents.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedEvents.asMap().entries.map((entry) {
                  int index = entry.key;
                  Event event = entry.value;
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: event.color,
                    ),
                    title: Text(
                      event.title,
                      style: TextStyle(fontSize: 20),
                    ),
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Wrap(
                            children: [

                              ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('刪除'),
                                onTap: () {
                                  _deleteEvent(index);
                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                leading: Icon(Icons.edit, color: Colors.blue),
                                title: Text('編輯'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _editEvent(index);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }).toList(),

              )// 顯示事件列表
            else
              const Text(" "),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(//AddEventPage按下按鈕後會跳轉到一個新增事件頁面
                      onSave: _addEvent,
                      initialDate: _selectedDay ?? DateTime.now()//如果 _selectedDay還沒點選，就預設為現在時間
                    ),
                  ),
                );
              },
              child: const Text(
                "+",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),//日曆新增事件按鈕
          ],
        ),
      ),
    );
  }
}
