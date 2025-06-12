import 'package:watchstore/models/data/customer.dart';

class Account {
  int? id;
  late String username;
  late String password;
  late int customerId;
  late Customer customer;

  Account({
    this.id,
    required this.username,
    required this.password,
    required this.customerId,
  });

  /// Chuyển đối tượng Account thành Map để lưu vào DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'customerId': customerId,
    };
  }

  /// Khôi phục đối tượng Account từ Map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      customerId: map['customerId'],
    );
  }
}
