import 'dart:convert';

import 'package:health_app/data/models/food.dart';
import 'package:health_app/data/models/nutrition_facts.dart';
import 'package:health_app/data/models/recipe.dart';
import 'package:health_app/data/sources/foods/foods_source.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart' as off;

class OpenFoodFactsFoodsSource implements FoodsSource {
  OpenFoodFactsFoodsSource({
    this.languages = const [off.OpenFoodFactsLanguage.ENGLISH],
    http.Client? httpClient,
    this.requestTimeout = const Duration(seconds: 6),
  }) : _http = httpClient ?? http.Client();

  final List<off.OpenFoodFactsLanguage> languages;
  final http.Client _http;
  final Duration requestTimeout;

  static const _searchBaseUrl = 'https://search.openfoodfacts.org/search';
  static const _searchFields = <String>[
    'code',
    'product_name',
    'product_name_en',
    'brands',
    'nutriments',
    'quantity',
    'serving_quantity',
    'categories_tags',
    'popularity_key',
    'unique_scans_n',
  ];

  static const _barcodeFields = <off.ProductField>[
    off.ProductField.BARCODE,
    off.ProductField.NAME,
    off.ProductField.BRANDS,
    off.ProductField.NUTRIMENTS,
    off.ProductField.QUANTITY,
    off.ProductField.SERVING_SIZE,
    off.ProductField.SERVING_QUANTITY,
    off.ProductField.CATEGORIES_TAGS,
  ];

  static const _beverageTag = 'en:beverages';
  static const _liquidUnits = <String>{
    'ml',
    'l',
    'cl',
    'dl',
    'fl',
    'floz',
    'floz.',
  };
  static const _beverageKeywords = <String>{
    'drink',
    'beverage',
    'juice',
    'soda',
    'cola',
    'water',
    'tea',
    'coffee',
    'milk',
    'smoothie',
    'lemonade',
    'shake',
    'nectar',
    'tonic',
    'cider',
    'beer',
    'lager',
    'ale',
    'wine',
    'champagne',
    'kombucha',
    'sok',
    'sokovi',
    'pijaca',
    'pijaco',
    'pijace',
    'voda',
    'nektar',
    'gazirana',
    'gazirano',
    'napitak',
    'napoj',
    'caj',
    'kava',
    'mleko',
    'pivo',
    'vino',
    'limonada',
  };

  @override
  Future<List<Food>> searchByText(
    String query, {
    int limit = 30,
    FoodSearchScope scope = FoodSearchScope.all,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final langs = languages.map((l) => l.offTag).join(',');
    final fetchSize = (limit * 3).clamp(1, 100);
    final uri = Uri.parse(_searchBaseUrl).replace(
      queryParameters: <String, String>{
        'q': trimmed,
        'page_size': fetchSize.toString(),
        'page': '1',
        'langs': langs.isEmpty ? 'en' : langs,
        'fields': _searchFields.join(','),
        'sort_by': '-popularity_key',
      },
    );

    final response = await _http.get(uri).timeout(requestTimeout);
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Search failed (${response.statusCode})',
        uri,
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return [];
    final hits = body['hits'];
    if (hits is! List) return [];

    final foods = <Food>[];
    final seen = <String>{};
    for (final hit in hits) {
      if (hit is! Map<String, dynamic>) continue;
      final food = _hitToFood(hit);
      if (food == null) continue;
      final key = _dedupeKey(food);
      if (!seen.add(key)) continue;
      foods.add(food);
      if (foods.length >= limit) break;
    }
    return foods;
  }

  String _dedupeKey(Food food) {
    final name = food.name.toLowerCase().trim();
    final brand = (food.brand ?? '').toLowerCase().trim();
    final kcal = food.facts.kcalPer100g.round();
    final protein = food.facts.proteinPer100g.round();
    final carbs = food.facts.carbsPer100g.round();
    final fat = food.facts.fatPer100g.round();
    return '$name|$brand|$kcal|$protein|$carbs|$fat';
  }

  @override
  Future<Food?> getByBarcode(String barcode) async {
    final config = off.ProductQueryConfiguration(
      barcode,
      languages: languages,
      fields: _barcodeFields,
      version: off.ProductQueryVersion.v3,
    );
    final result = await off.OpenFoodAPIClient.getProductV3(config);
    final product = result.product;
    if (product == null) return null;
    return _productToFood(product);
  }

  @override
  Future<List<Food>> listCustomFoods() async => const [];

  @override
  Future<Food> saveCustomFood(Food food) =>
      throw UnsupportedError('OpenFoodFacts source is read-only');

  @override
  Future<void> deleteCustomFood(String id) =>
      throw UnsupportedError('OpenFoodFacts source is read-only');

  @override
  Future<List<Recipe>> listRecipes() async => const [];

  @override
  Future<Recipe> saveRecipe(Recipe recipe) =>
      throw UnsupportedError('OpenFoodFacts source is read-only');

  @override
  Future<void> deleteRecipe(String id) =>
      throw UnsupportedError('OpenFoodFacts source is read-only');

  Food? _hitToFood(Map<String, dynamic> hit) {
    final barcode = (hit['code'] as Object?)?.toString();
    if (barcode == null || barcode.isEmpty) return null;

    final brand = _firstBrand(hit['brands'] as Object?);
    final name = _firstNonEmpty([
          hit['product_name'] as Object?,
          hit['product_name_en'] as Object?,
        ]) ??
        brand;
    if (name == null) return null;

    final nutriments = hit['nutriments'];
    if (nutriments is! Map<String, dynamic>) return null;

    final kcal = _kcalPer100g(nutriments);
    if (kcal == null) return null;

    return Food(
      id: 'off:$barcode',
      name: name,
      brand: brand,
      barcode: barcode,
      defaultServingGrams: _toDouble(hit['serving_quantity']),
      isBeverage: _detectBeverage(
        categoriesTags: hit['categories_tags'],
        quantity: hit['quantity']?.toString(),
        name: name,
      ),
      source: FoodSourceKind.openFoodFacts,
      facts: NutritionFacts(
        kcalPer100g: kcal,
        proteinPer100g: _toDouble(nutriments['proteins_100g']) ?? 0,
        carbsPer100g: _toDouble(nutriments['carbohydrates_100g']) ?? 0,
        fatPer100g: _toDouble(nutriments['fat_100g']) ?? 0,
        sugarPer100g: _toDouble(nutriments['sugars_100g']) ?? 0,
      ),
    );
  }

  bool _detectBeverage({
    Object? categoriesTags,
    String? quantity,
    String? name,
  }) {
    if (_hasBeverageTag(categoriesTags)) return true;
    if (_quantityLooksLiquid(quantity)) return true;
    if (_nameLooksLikeBeverage(name)) return true;
    return false;
  }

  bool _hasBeverageTag(Object? tags) {
    if (tags is! List) return false;
    for (final tag in tags) {
      if (tag != null && tag.toString() == _beverageTag) return true;
    }
    return false;
  }

  bool _quantityLooksLiquid(String? quantity) {
    if (quantity == null) return false;
    final lower = quantity.toLowerCase().replaceAll(' ', '');
    if (lower.isEmpty) return false;
    final match = RegExp(r'([a-z]+)$').firstMatch(lower);
    if (match == null) return false;
    final unit = match.group(1);
    return unit != null && _liquidUnits.contains(unit);
  }

  bool _nameLooksLikeBeverage(String? name) {
    if (name == null || name.isEmpty) return false;
    final tokens = name
        .toLowerCase()
        .split(RegExp('[^a-z0-9]+'))
        .where((t) => t.isNotEmpty);
    for (final token in tokens) {
      if (_beverageKeywords.contains(token)) return true;
    }
    return false;
  }

  Food? _productToFood(off.Product product) {
    final barcode = product.barcode;
    final name = (product.productName ?? '').trim();
    if (barcode == null || barcode.isEmpty || name.isEmpty) return null;

    final nutriments = product.nutriments;
    if (nutriments == null) return null;

    var kcal = nutriments.getValue(
      off.Nutrient.energyKCal,
      off.PerSize.oneHundredGrams,
    );
    if (kcal == null) {
      final kj = nutriments.getValue(
        off.Nutrient.energyKJ,
        off.PerSize.oneHundredGrams,
      );
      if (kj != null) kcal = kj * 0.239;
    }
    if (kcal == null) return null;

    return Food(
      id: 'off:$barcode',
      name: name,
      brand: _firstBrand(product.brands),
      barcode: barcode,
      defaultServingGrams: _toDouble(product.servingQuantity),
      isBeverage: _detectBeverage(
        categoriesTags: product.categoriesTags,
        quantity: product.quantity,
        name: name,
      ),
      source: FoodSourceKind.openFoodFacts,
      facts: NutritionFacts(
        kcalPer100g: kcal,
        proteinPer100g: nutriments.getValue(
              off.Nutrient.proteins,
              off.PerSize.oneHundredGrams,
            ) ??
            0,
        carbsPer100g: nutriments.getValue(
              off.Nutrient.carbohydrates,
              off.PerSize.oneHundredGrams,
            ) ??
            0,
        fatPer100g: nutriments.getValue(
              off.Nutrient.fat,
              off.PerSize.oneHundredGrams,
            ) ??
            0,
        sugarPer100g: nutriments.getValue(
              off.Nutrient.sugars,
              off.PerSize.oneHundredGrams,
            ) ??
            0,
      ),
    );
  }

  double? _kcalPer100g(Map<String, dynamic> nutriments) {
    final kcal = _toDouble(nutriments['energy-kcal_100g']);
    if (kcal != null) return kcal;
    final kj = _toDouble(nutriments['energy-kj_100g']) ??
        _toDouble(nutriments['energy_100g']);
    if (kj != null) return kj * 0.239;
    return null;
  }

  String? _firstNonEmpty(List<Object?> candidates) {
    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  String? _firstBrand(Object? brands) {
    if (brands == null) return null;
    if (brands is List) {
      for (final b in brands) {
        if (b == null) continue;
        final s = b.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return null;
    }
    final first = brands.toString().split(',').first.trim();
    return first.isEmpty ? null : first;
  }

  double? _toDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s.replaceAll(',', '.'));
  }
}
