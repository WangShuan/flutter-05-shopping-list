import 'package:flutter/material.dart';

import '../models/category.dart';

final categories = {
  Categories.vegetables: Category(
    '蔬菜',
    const Color.fromARGB(255, 157, 255, 0),
  ),
  Categories.fruit: Category(
    '水果',
    const Color.fromARGB(255, 255, 255, 0),
  ),
  Categories.necessary: Category(
    '日用品',
    const Color.fromARGB(255, 107, 70, 209),
  ),
  Categories.meat: Category(
    '肉類',
    const Color.fromARGB(255, 255, 102, 0),
  ),
  Categories.dairy: Category(
    '飲品',
    const Color.fromARGB(255, 138, 218, 236),
  ),
  Categories.snack: Category(
    '零食類',
    const Color.fromARGB(255, 255, 0, 136),
  ),
  Categories.clothes: Category(
    '服飾',
    const Color.fromARGB(255, 255, 149, 0),
  ),
  Categories.toy: Category(
    '玩具',
    const Color.fromARGB(255, 0, 255, 238),
  ),
  Categories.other: Category(
    '其他',
    const Color.fromARGB(255, 150, 150, 150),
  ),
};
