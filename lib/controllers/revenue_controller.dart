// lib/controllers/revenue_controller.dart
import 'package:flutter/material.dart';
import '../models/data/database_helper.dart';
import 'package:flutter/foundation.dart';

class RevenueController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  double _totalRevenue = 0.0;
  int _successfulOrdersCount = 0;
  int _cancelledOrdersCount = 0;
  int _pendingOrdersCount = 0;
  int _totalOrdersCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  double get totalRevenue => _totalRevenue;
  int get successfulOrdersCount => _successfulOrdersCount;
  int get cancelledOrdersCount => _cancelledOrdersCount;
  int get pendingOrdersCount => _pendingOrdersCount;
  int get totalOrdersCount => _totalOrdersCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RevenueController() {
    fetchRevenueData();
  }

  Future<void> fetchRevenueData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _totalRevenue = await _dbHelper.getTotalRevenue();
      _successfulOrdersCount = await _dbHelper.countOrdersByStatus('thành công');
      _cancelledOrdersCount = await _dbHelper.countOrdersByStatus('đã hủy');
      _pendingOrdersCount = await _dbHelper.countOrdersByStatus('đang chờ');
      
      final allOrders = await _dbHelper.getAllOrders();
      _totalOrdersCount = allOrders.length;


      if (kDebugMode) {
        print("RevenueController: Data fetched successfully.");
        print("Total Revenue: $_totalRevenue");
        print("Successful Orders: $_successfulOrdersCount");
        print("Cancelled Orders: $_cancelledOrdersCount");
        print("Pending Orders: $_pendingOrdersCount");
        print("Total Orders: $_totalOrdersCount");
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch revenue data: $e';
      if (kDebugMode) {
        print("RevenueController Error: $_errorMessage");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
