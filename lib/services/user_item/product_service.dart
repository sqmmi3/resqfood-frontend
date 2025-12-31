import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final http.Client _client;
  final GenerativeModel _aiModel;

  ProductService(this._aiModel, {http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>?> fetchProductData(String barcode) async {
    final url = Uri.parse(
      "https://world.openfoodfacts.org/api/v2/product/$barcode.json?fields=product_name,image_front_url,categories"
    );

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final String name = data['product']['product_name'] ?? "Unknown product";
          final String rawCategories = data['product']['categories'] ?? "";

          final String category = await getAiSuggestedCategory(name, rawCategories);
          int ruleDays = _getOpenedRuleForCategory(category);

          debugPrint("AI Categorized as: $category. Rule: $ruleDays days");

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

  Future<String> getAiSuggestedCategory(String name, String details) async {
    try {
      final prompt = '''
        Task: Categorize the product "$name" ($details).
        
        Allowed Categories:
        FRUIT, VEGETABLE, GRAIN, PROTEIN, DAIRY, SWEETS, BEVERAGE, READY_MEAL, SPICE, BAKING, FROZEN, CANNED, PANTRY.

        Classification Guide:
        - READY_MEAL: Pizza, Lasagna, Instant Soup, Microwave meals.
        - BAKING: Flour, Sugar, Yeast, Baking Soda.
        - SPICE: Salt, Pepper, Dried Herbs, Curry Powder.
        - SWEETS: Chocolate, Candy, Chips, Cookies.
        - PANTRY: Jars/Spreads (Nutella, Jam), Honey, Oils, Vinegar.
        - GRAIN: Bread, Rice, Pasta, Cereal.
        - CANNED/FROZEN: Priority goes here if packaging is mentioned.

        RESPONSE: Return ONLY the category name in uppercase. No extra text.
      ''';

      debugPrint("--- CHAT SENT TO GEMINI ---");
      debugPrint(prompt);
      debugPrint("---------------------------");

      final response = await _aiModel.generateContent([Content.text(prompt)]);
      final result = response.text?.trim().toUpperCase() ?? "PANTRY";
      debugPrint("--- GEMINI REPLIED ---");
      debugPrint(result);

      const valid = [
        'FRUIT', 'VEGETABLE', 'GRAIN', 'PROTEIN', 'DAIRY', 
        'SWEETS', 'BEVERAGE', 'READY_MEAL', 'SPICE', 
        'BAKING', 'FROZEN', 'CANNED', 'PANTRY'
      ];

      return valid.contains(result) ? result : "PANTRY";
      
    } catch (e) {
      return "PANTRY";
    }
  }

  int _getOpenedRuleForCategory(String category) {
    switch (category) {
      case 'DAIRY': return 5;
      case 'PROTEIN': return 3;
      case 'FRUIT': return 7;
      case 'VEGETABLE': return 7; 
      case 'READY_MEAL': return 2;
      case 'BEVERAGE': return 10;
      case 'FROZEN': return 90;
      case 'PANTRY': return 60;
      case 'CANNED': return 3;
      case 'GRAIN': return 180;
      case 'BAKING': return 365;
      case 'SPICE': return 730;
      case 'SWEETS': return 30;
      default: return 3;
    }
  }
}