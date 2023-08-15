import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/categories.dart';
import '../models/grocery_item.dart';
import './new_item_screen.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> groceries = [];
  bool _isLoading = true;
  String _error = '';
  String url = 'flutter-test-7cb64-default-rtdb.asia-southeast1.firebasedatabase.app';
  void _loadData() async {
    final List<GroceryItem> arr = [];
    http.Response res;
    try {
      res = await http.get(Uri.https(url, 'shopping-list.json'));
    } catch (e) {
      setState(() {
        _error = '載入失敗，請稍後重試。';
        _isLoading = false;
      });
      return;
    }
    if (res.statusCode >= 400) {
      setState(() {
        _error = '載入失敗，請稍後重試。';
      });
      _isLoading = false;
      return;
    }
    if (res.body != 'null') {
      final Map<String, dynamic> resData = json.decode(res.body);
      for (var item in resData.entries) {
        final cate = categories.entries.firstWhere(
          (c) => c.value.title == item.value['category'],
        );
        arr.insert(
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
      groceries = arr;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () async {
              final item = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NewItemScreen(),
              ));
              if (item != null) {
                setState(() {
                  groceries.insert(0, item);
                });
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(_error),
                )
              : groceries.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, i) => Dismissible(
                        key: ValueKey(groceries[i].id),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) async {
                          final item = groceries[i];
                          http.Response res;
                          setState(() {
                            groceries.remove(item);
                          });
                          try {
                            res = await http.delete(Uri.https(
                              url,
                              'shopping-list/${item.id}.json',
                            ));
                          } catch (e) {
                            setState(() {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('刪除失敗，請稍後重試。'),
                                ),
                              );
                              groceries.insert(i, item);
                            });
                            return;
                          }
                          if (res.statusCode >= 400) {
                            setState(() {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('刪除失敗，請稍後重試。'),
                                ),
                              );
                              groceries.insert(i, item);
                            });
                          }
                        },
                        background: ColoredBox(
                          color: Theme.of(context).colorScheme.error,
                          child: const Row(
                            children: [
                              SizedBox(width: 8),
                              Icon(Icons.delete),
                              Spacer(),
                            ],
                          ),
                        ),
                        child: ListTile(
                          leading: ColoredBox(
                            color: groceries[i].category.color,
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                            ),
                          ),
                          title: Text(groceries[i].name),
                          trailing: Text(groceries[i].quantity.toString()),
                        ),
                      ),
                      itemCount: groceries.length,
                    )
                  : const Center(
                      child: Text('尚未添加任何項目。'),
                    ),
    );
  }
}
