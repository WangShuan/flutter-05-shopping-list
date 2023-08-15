# 使用 flutter 建構 Shopping list APP

筆記連結：<https://hackmd.io/eVIn65crQRmThVxjtA5HVA?view>

該專案主要學習使用表單小部件進行驗證與提交、以及通過 https 發送請求將資料與後端(本案利用 Firebase 的 Realtime Database 當作後端練習)進行交互。

## Form 表單小部件用法

1. 建立 formKey 綁定表單小部件
2. 通過 `formKey.currentState!.validate()` 驗證表單欄位
3. 通過 `formKey.currentState!.save()` 提交表單
4. 通過 `formKey.currentState!.reset()` 清空表單欄位
5. 在 Form 小部件中要使用 `TextFormField` 小部件
6. 在 `TextFormField` 小部件中可通過 `validator` 驗證欄位、通過 `onSaved` 保存欄位值

```dart
// 建立 form key
final GlobalKey<FormState> formKey = GlobalKey<FormState>();

// 設定提交表單要執行的事件
void submitForm() {
  if (formKey.currentState!.validate()) { // 驗證表單
    formKey.currentState!.save(); // 提交表單
    Navigator.of(context).pop( // 通過 pop 方法，傳入 GroceryItem 對象並回上一頁
      GroceryItem(
        id: DateTime.now().toString(),
        name: name,
        quantity: qty,
        category: category,
      ),
    );
  }
}

Form(
  key: formKey,
  child: SingleChildScrollView( // 使用 SingleChildScrollView 讓畫面可滾動
    child: Column(
      children: [
        TextFormField( // 設置名稱輸入框
          decoration: const InputDecoration(
            labelText: 'Name',
            contentPadding: EdgeInsets.zero,
          ),
          maxLength: 30, // 限制最長字數
          validator: (val) => val == null || val.isEmpty || val.trim().length < 2 ? 'Name must be at least 2 characters.' : null, // 進行驗證
          onSaved: (newValue) => name = newValue!, // 提交表單時要執行的事件，這邊將 name 保存下來
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField( // 設置數量輸入框
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: const TextInputType.numberWithOptions(signed: true), // 設置鍵盤類型
                validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null || int.tryParse(val)! <= 0 ? 'Quantity must be an integer.' : null, // 進行驗證
                onSaved: (newValue) => qty = int.parse(newValue!), // 提交表單時要執行的事件，這邊將 qty 保存下來
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField( // 設置分類下拉
                decoration: const InputDecoration(
                  labelText: 'Category',
                  contentPadding: EdgeInsets.zero,
                ),
                items: [
                  for (final c in categories.entries) // 通過 entries 將物件轉換為 key 與 value 的陣列以進行遍歷
                    DropdownMenuItem(
                      value: c.value,
                      child: Row(
                        children: [
                          ColoredBox(
                            color: c.value.color,
                            child: const SizedBox(width: 20, height: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(c.value.title)
                        ],
                      ),
                    ),
                ],
                value: category,
                onChanged: (value) { // 選中時保存當前的 category
                  category = value!;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  formKey.currentState!.reset(); // 通過 reset() 方法清空表單欄位
                },
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: submitForm,
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: const Text('Submit'),
                ),
              ),
            )
          ],
        )
      ],
    ),
  ),
)
```

## http 套件用法

在首頁，簡單通過 `ListView.builder` 建立列表，顯示標題、分類色塊、數量，接著在 firebase 中建立專案，並啟用 Realtime Database，將規則設為 true 後即可讀取與寫入，接著複製 firebase 資料庫的網址到檔案中設為變數 `url` 備用。

接著開啟終端機，於項目根目錄執行命令 `flutter pub add http` 安裝 `http` 套件，於首頁中引入並使用：

```dart
import 'package:http/http.dart' as http; // 引入 http 套件為 http
List<GroceryItem> groceries = []; // 放所有數據
bool _isLoading = true; // 判斷是否載入中
String _error = ''; // 放錯誤訊提示息
String url = '<your-id>.<資料庫位置>.firebasedatabase.app'; // 資料庫網址
void _loadData() async {
  final List<GroceryItem> arr = [];
  http.Response res;
  try {
    res = await http.get(Uri.https(url, 'shopping-list.json')); // 通過 http.get 發送請求獲取數據
  } catch (e) {
    setState(() {
      _error = '載入失敗，請稍後重試。';
      _isLoading = false;
    });
    return;
  }
  if (res.body != 'null') {
    final Map<String, dynamic> resData = json.decode(res.body); // 將 json 轉為 map 對象
    for (var item in resData.entries) { // 通過 entries 遍歷 resData
      final cate = categories.entries.firstWhere( // 透過判斷 category.title 獲取實際的 category
        (c) => c.value.title == item.value['category'],
      );
      arr.insert( // 往最開頭添加 GroceryItem 項目
        0,
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: cate.value,
        ),
      );
    }
  }
  setState(() {
    groceries = arr; // 將 arr 取代目前的 groceries 資料
    _isLoading = false; // 結束載入中狀態
  });
}
```

1. `http.get()` 中需傳入 `Uri` 而非 `url`
2. 可用 `try-catch` 處理錯誤
3. 需通過 `json.decode(res.body)` 將獲取到的數據轉為物件
4. 可通過 `res.statusCode >= 400` 判斷請求是否發生錯誤

> firebase API 說明文件：<https://firebase.google.com/docs/reference/rest/database?hl=zh-tw>