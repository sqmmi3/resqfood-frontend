import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class ProductService {
  Future<Map<String, String>?> fetchProductData(String barcode) async {
    final url = Uri.parse(
      "https://world.openfoodfacts.org/api/v2/product/$barcode.json?fields=product_name,image_front_url,categories"
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          String rawCategories = data['product']['categories'] ?? "";

          final String category = _mapToAppCategory(rawCategories);
          final int ruleDays = _getOpenedRuleForCategory(category);

          debugPrint(response.body.toString());

          return {
            'name': data['product']['product_name'] ?? "Unknown product",
            'image': data['product']['image_front_url'] ?? "",
            'category': category,
            'openedRule': "$ruleDays days",
          };
        }
      }
    } catch (e) {
      debugPrint("Product lookup failed: $e");
    }
    return null;
  }

  String _mapToAppCategory(String raw) {
    debugPrint(raw);
    final text = raw.toUpperCase();
    if ((text.contains("GRAPES") || text.contains("APPLE") || text.contains("BANANA") || text.contains("KIWI") || text.contains("ORANGE")) && !(text.contains("CARBONATED") || text.contains("SODA") || text.contains("DRINK") || text.contains("WATER") || text.contains("JUICE"))) return "FRUIT";
    if ((text.contains("BEVERAGE") || text.contains("SODA") || text.contains("DRINK") || text.contains("WATER") || text.contains("JUICE")) && !text.contains("CHOCOLATE")) return "BEVERAGE";
    if (text.contains("FRUIT")) return "FRUIT";
    if (text.contains("VEGETABLE") || text.contains("PLANT-BASED")) return "VEGETABLE";
    if (text.contains("DAIRY") || text.contains("MILK") || text.contains("CHEESE") || text.contains("YOGURT")) return "DAIRY";
    if (text.contains("MEAT") || text.contains("CHICKEN") || text.contains("FISH") || text.contains("PROTEIN")) return "PROTEIN";
    if ((text.contains("SWEET") || text.contains("CHOCOLATE") || text.contains("DESSERT") || text.contains("BISCUIT") || text.contains("SNACK")) && !text.contains("HAZELNUTS")) return "SWEETS";
    if (text.contains("GRAIN") || text.contains("CEREAL") || text.contains("PASTA") || text.contains("RICE") || text.contains("BREAD")) return "GRAIN";
    if (text.contains("FROZEN")) return "FROZEN";
    if (text.contains("CANNED")) return "CANNED";
    if (text.contains("SPICE") || text.contains("HERB") || text.contains("CONDIMENT")) return "SPICE";
    if (text.contains("BAKING") || text.contains("FLOUR")) return "BAKING";
    if (text.contains("READY-TO-EAT") || text.contains("MEAL")) return "READY_MEAL";
    return "PANTRY";
  }

  int _getOpenedRuleForCategory(String category) {
    switch (category) {
      case 'DAIRY': return 7;
      case 'PROTEIN': return 3;
      case 'FRUIT': return 5;
      case 'VEGETABLE': return 5; 
      case 'READY_MEAL': return 3;
      case 'BEVERAGE': return 10;
      case 'FROZEN': return 30;
      case 'PANTRY': return 60;
      case 'CANNED': return 3;
      case 'GRAIN': return 90;
      case 'BAKING': return 180;
      case 'SPICE': return 365;
      case 'SWEETS': return 14;
      default: return 3;
    }
  }
}