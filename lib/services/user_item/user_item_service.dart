import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class UserItemService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<UserItem>> getUserItems() async {
    final token = await AuthService.getStoredToken();

    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/user-items"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => UserItem.fromJson(e)).toList();
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      throw Exception("Unauthorized. Please login again.");
    } else {
      throw Exception("Failed to fetch items: ${response.body}");
    }
  }

  List<GroupedUserItem> groupUserItems(List<UserItem> items) {
    final Map<String, List<UserItem>> groupedMap = {};

    for (var item in items) {
      groupedMap.putIfAbsent(item.itemName, () => []).add(item);
    }

    final List<GroupedUserItem> groupedItems = [];

    groupedMap.forEach((name, itemList) {
      final bool isOpen = itemList.any((item) => item.openedDate != null);
      final List<DateTime> effectiveDates = itemList.map((item) {
        final expiration = item.expirationDate;

        if (item.openedDate == null) {
          return expiration;
        }

        final openedDate = item.openedDate!;
        final ruleDate = openedDate.add(Duration(days: item.openedRule!));

        return ruleDate.isBefore(expiration) ? ruleDate : expiration;
      }).toList();

      effectiveDates.sort((a, b) => a.compareTo(b));

      groupedItems.add(GroupedUserItem(
        itemName: name,
        type: items.first.type,
        amount: itemList.length,
        earliestExpiration: effectiveDates.first,
        isOpen: isOpen,
        allInstances: itemList,
      ));
    });

    groupedItems.sort((a, b) => a.earliestExpiration.compareTo(b.earliestExpiration));

    return groupedItems;
  }

  Future<void> saveUserItemBatch(List<UserItem> items) async {
    final token = await AuthService.getStoredToken();

    final response = await http.put(
      Uri.parse("$baseUrl/user-items/batch"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(items.map((i) => i.toJson()).toList()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint("SERVER ERROR STATUS: ${response.statusCode}");
      debugPrint("SERVER ERROR BODY: ${response.body}");
      throw Exception("Server error: ${response.body}");
    }
  }

  Future<void> deleteUserItem(int id) async {
    final token = await AuthService.getStoredToken();
    
    final response = await http.delete(
      Uri.parse("$baseUrl/user-items/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete item from server");
    }
  }
}