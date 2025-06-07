import 'package:flutter/material.dart';
import 'package:watchstore/models/data/database_helper.dart';
import 'package:watchstore/models/data/order.dart';
import 'package:watchstore/models/data/order_detail.dart';
import 'package:watchstore/models/data/orderdetail_attributeId.dart';

class OrderController extends ChangeNotifier {
  Future<void> addOrder(Order order, List<OrderDetail> orderDetails) async {
    final db = await DatabaseHelper.database;

    try {
      await db.transaction((txn) async {
        int orderId = await txn.insert('Order', order.toMap());

        for (var detail in orderDetails) {
          detail.orderId = orderId;
          int orderDetailId = await txn.insert('OrderDetail', detail.toMap());
          if (detail.orderDetailAttributeId?.isNotEmpty ?? false) {
            for (var oda in detail.orderDetailAttributeId!) {
              oda.orderDetailId = orderDetailId;
              await txn.insert(
                'OrderDetailAttributeId',
                oda.toMap(),
              );
            }
          }
        }
      });
      notifyListeners();
    } catch (e) {
      print('Error inserting order: $e');
    }
  }

  Future<List<Order>> getOrderByCustomer(int customerId) async {
    final db = await DatabaseHelper.database;
    var result = await db.query(
      'Order',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
    if (result.isNotEmpty) {
      return result.map((map) => Order.fromMap(map)).toList();
    }
    return [];
  }

  Future<List<OrderDetail>> getOrderDetailByOrderId(int orderId) async {
    final db = await DatabaseHelper.database;

    // Bước 1: Lấy danh sách OrderDetail theo orderId
    final List<Map<String, dynamic>> orderDetailMaps = await db.query(
      'OrderDetail',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );

    // Bước 2: Tạo danh sách OrderDetail kèm thông tin OrderDetailAttributeId
    List<OrderDetail> orderDetails = [];
    for (var map in orderDetailMaps) {
      OrderDetail orderDetail = OrderDetail.fromMap(map);
      // Lấy các OrderDetailAttributeId liên quan đến orderDetail.id
      if (orderDetail.id != null) {
        final attributeMaps = await db.query(
          'OrderDetailAttributeId',
          where: 'orderDetailId = ?',
          whereArgs: [orderDetail.id],
        );

        if (attributeMaps.isNotEmpty) {
          final tmp = attributeMaps
                  .map((am) => OrderDetailAttributeId.fromMap(am))
                  .toList();
          orderDetail.orderDetailAttributeId = tmp;
        } else {
          orderDetail.orderDetailAttributeId = null;
        }
      }

      orderDetails.add(orderDetail);
    }

    return orderDetails;
  }
}
