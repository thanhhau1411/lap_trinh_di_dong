import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watchstore/models/data/customer.dart';
import 'package:watchstore/models/data/database_helper.dart';

class CustomerController extends ChangeNotifier {
  late Database _db;
  Future<void> updateCustomer(Customer customer) async {
    _db = await DatabaseHelper.database;

    //  Đọc dữ liệu hiện tại từ DB
    final current = await _db.query(
      'Customer',
      where: 'id = ?',
      whereArgs: [customer.id],
    );

    if (current.isEmpty) {
      throw Exception('Customer with ID ${customer.id} not found');
    }

    final old = Customer.fromMap(current.first);

    //  update giá trị mới (chỉ update nếu khác null)
    final updated = Customer(
      id: old.id,
      fullName: customer.fullName.isNotEmpty ? customer.fullName : old.fullName,
      email: customer.email ?? old.email,
      phoneNumer: customer.phoneNumer.isNotEmpty ? customer.phoneNumer : old.phoneNumer,
      address: customer.address.isNotEmpty ? customer.address : old.address,
      imageUrl: customer.imageUrl ?? old.imageUrl,
    );

    // Update vào DB
    await _db.update(
      'Customer',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [updated.id],
    );

    notifyListeners();
  }
}
