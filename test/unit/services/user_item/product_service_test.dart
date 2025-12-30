import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/user_item/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'product_service_test.mocks.dart';

@GenerateMocks([http.Client])

void main() {
  late ProductService productService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    productService = ProductService(client: mockClient);
  });

  group('ProductService - fetchProductData', () {
    test('returns correctly mapped product data on success', () async {
      final mockApiResponse = {
        'status': 1,
        'product': {
          'product_name': 'Organic Whole Milk',
          'image_front_url': 'http://image.com/milk.jpg',
          'categories': 'Dairies, Milks, Fresh milk'
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockApiResponse), 200)
      );

      final result = await productService.fetchProductData('12345678');

      expect(result?['name'], 'Organic Whole Milk');
      expect(result?['category'], 'DAIRY');
      expect(result?['openedRule'], '7 days');
    });

    test('returns null if product status is not 1', () async {
      final mockApiResponse = {'status': 0, 'product': null};

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockApiResponse), 200)
      );

      final result = await productService.fetchProductData('0000');

      expect(result, isNull);
    });
  });

  group('ProductService - Category Mapping Logic', () {
    
    test('maps "Apple" to FRUIT', () async {
      final mockResponse = {
        'status': 1,
        'product': {'categories': 'Fresh Apples, Fruit'}
      };
      when(mockClient.get(any)).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await productService.fetchProductData('1');
      expect(result?['category'], 'FRUIT');
    });

    test('maps "Chicken" to PROTEIN', () async {
      final mockResponse = {
        'status': 1,
        'product': {'categories': 'Meat, Poultry, Chicken'}
      };
      when(mockClient.get(any)).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await productService.fetchProductData('1');
      expect(result?['category'], 'PROTEIN');
    });
  });
}