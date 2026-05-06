import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';

class AdminService {
  final supabase = Supabase.instance.client;

  Future<int> getUsersCount() async {
    final data = await supabase.from('users').select('id');
    return data.length;
  }

  Future<int> getProductsCount() async {
    final data = await supabase.from('products').select('id');
    return data.length;
  }

  Future<int> getOrdersCount() async {
    final data = await supabase.from('orders').select('id');
    return data.length;
  }

  Future<double> getRevenue() async {
    final data = await supabase.from('orders').select('total');

    double revenue = 0;
    for (var o in data) {
      revenue += (o['total'] ?? 0) * 0.10; // 10% commission
    }
    return revenue;
  }

  Future<Map<String, dynamic>> getStats() async {
    final users = await getUsersCount();
    final products = await getProductsCount();
    final orders = await getOrdersCount();
    final revenue = await getRevenue();

    return {
      "users": users,
      "products": products,
      "orders": orders,
      "revenue": revenue,
    };
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

  }
}