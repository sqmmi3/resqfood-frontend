import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/item.dart';


class ItemService {
  late final String baseUrl;

  ItemService() {
    if (kIsWeb) {
      baseUrl = 'http://localhost:8000';
    } else {
      baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
    }
  }

  Future<List<Item>> fetchAllItems() async {
    final client = http.Client();
    try {
      final response = await client.get(Uri.parse('$baseUrl/items'),
      )
      .timeout(const Duration(seconds: 10), 
      onTimeout: () => throw TimeoutException('Request took too long'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Item.fromJson(item)).toList();
      } else {
        throw HttpException('Failed with status: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<Item> postItem(Item item) async {
    final client = http.Client();
    try {
      final requestBody = {
        'name': item.name,
        'category': item.category,
        'quantity': item.quantity,
        'expirationDate': item.expirationDate,
        'openedDate': item.openedDate,
        'description': item.description,
      };
      
      final response = await client.post(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request took too long'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Item.fromJson(data);
      } else {
        throw HttpException('Failed with status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<Item> updateItem(int itemId, Item item) async {
    final client = http.Client();
    try {
      final requestBody = {
        'name': item.name,
        'category': item.category,
        'quantity': item.quantity,
        'expirationDate': item.expirationDate,
        'openedDate': item.openedDate,
        'description': item.description,
      };
      
      final response = await client.put(
        Uri.parse('$baseUrl/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request took too long'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Item.fromJson(data);
      } else {
        throw HttpException('Failed with status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> deleteItem(int itemId) async {
    final client = http.Client();
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request took too long'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw HttpException('Failed with status: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}