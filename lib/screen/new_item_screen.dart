import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/grocery_item.dart';
import '../data/categories.dart';
import '../models/category.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  bool _isLoading = false;
  String _error = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String name = '';
  int qty = 1;
  Category category = categories[Categories.vegetables]!;
  Future<void> submitForm() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      formKey.currentState!.save();
      try {
        http
            .post(
              Uri.https(
                'flutter-test-7cb64-default-rtdb.asia-southeast1.firebasedatabase.app',
                'shopping-list.json',
              ),
              body: json.encode(
                {
                  'name': name,
                  'quantity': qty,
                  'category': category.title,
                },
              ),
            )
            .then(
              (value) => Navigator.of(context).pop(
                GroceryItem(
                  id: json.decode(value.body)['name'],
                  name: name,
                  quantity: qty,
                  category: category,
                ),
              ),
            );
      } catch (e) {
        setState(() {
          _error = '錯誤，請稍後重試。';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Grocery'),
      ),
      body: _error.isNotEmpty
          ? Center(
              child: Text(_error),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLength: 30,
                        validator: (val) => val == null || val.isEmpty || val.trim().length < 2 ? 'Name must be at least 2 characters.' : null,
                        onSaved: (newValue) => name = newValue!,
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                contentPadding: EdgeInsets.zero,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(signed: true),
                              validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null || int.tryParse(val)! <= 0 ? 'Quantity must be an integer.' : null,
                              onSaved: (newValue) => qty = int.parse(newValue!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                contentPadding: EdgeInsets.zero,
                              ),
                              items: [
                                for (final c in categories.entries)
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
                              onChanged: (value) {
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
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      formKey.currentState!.reset();
                                    },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isLoading ? null : submitForm,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text('Submit'),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
