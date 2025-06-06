import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watchstore/models/data/customer.dart';
import 'package:watchstore/models/data/database_helper.dart';

class AuthController extends ChangeNotifier {
  late Database _db;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Customer? customerInfo;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<Customer?> loginUser(String username, String password) async {
    _db = await DatabaseHelper.database;
    var result = await _db.rawQuery(
      'select c.* from Account a join Customer c on c.id = a.customerId where a.username = ? and a.password = ?',
      [username, password],
    );
    if (result.isNotEmpty) {
      return Customer.fromMap(result.first);
    }
    return null;
  }

  Future<String?> registerUser(
    String username,
    String password,
    Customer customer,
  ) async {
    _db = await DatabaseHelper.database;

    try {
      await _db.transaction((txn) async {
        // Insert Customer
        int customerId = await txn.insert('Customer', customer.toMap());

        // Insert Account with foreign key to Customer
        await txn.insert('Account', {
          'username': username,
          'password': password,
          'customerId': customerId,
        });
      });

      notifyListeners(); // Optional
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
