import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  necessary,
  meat,
  dairy,
  snack,
  clothes,
  toy,
  other,
}

class Category {
  final String title;
  final Color color;

  Category(this.title, this.color);
}
