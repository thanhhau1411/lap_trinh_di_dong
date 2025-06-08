import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watchstore/models/data/brand.dart';
import 'package:watchstore/models/data/database_helper.dart';

class BrandController extends ChangeNotifier {
  late Database _db;
  
  Future<List<Brand>> loadAll() async {
    _db = await DatabaseHelper.database;
    final result = await _db.query('Brand');
    if(result.isNotEmpty) {
      return result.map((map) => Brand.fromMap(map)).toList();
    }
    return <Brand>[];
  }
}