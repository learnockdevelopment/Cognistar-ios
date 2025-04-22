import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/guest_service/categories_service.dart';



class CategoryDataManagerProvider extends ChangeNotifier {
  // Data variables
  bool isLoading = true;
  List<CategoryModel> trendCategories = [];
  List<CategoryModel> categories = [];

  // Method to fetch categories data
  Future<void> getCategoriesData() async {
    try {
      categories = await CategoriesService.categories();
      notifyListeners(); // Notify listeners after updating the categories
    } catch (error) {
      // Handle error
      rethrow;
    }
  }

  // Method to fetch trend categories data
  Future<void> getTrendCategoriesData() async {
    try {
      trendCategories = await CategoriesService.trendCategories();
      notifyListeners(); // Notify listeners after updating the trend categories
    } catch (error) {
      // Handle error
      rethrow;
    }
  }

  // Method to fetch all data (both categories and trend categories)
  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners(); // Notify listeners before fetching data

    await Future.wait([
      getCategoriesData(),
      getTrendCategoriesData(),
    ]);

    isLoading = false;
    notifyListeners(); // Notify listeners after all data is fetched
  }
}