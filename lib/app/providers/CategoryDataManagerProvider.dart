import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../models/category_model.dart';
import '../models/course_model.dart';
import '../services/guest_service/categories_service.dart';
import '../services/guest_service/course_service.dart';

class CategoryDataManagerProvider extends ChangeNotifier {
  // Data variables
  bool isLoading = true;
  List<CategoryModel> trendCategories = [];
  List<CategoryModel> categories = [];
  Map<int, List<CourseModel>> categoryCourses = {};

  // Method to fetch categories data
  Future<void> getCategoriesData() async {
    try {
      categories = await CategoriesService.categories();
      developer.log('Fetched ${categories.length} categories');
      notifyListeners();
    } catch (error) {
      print('Error fetching categories: $error');
      rethrow;
    }
  }

  // Method to fetch trend categories data
  Future<void> getTrendCategoriesData() async {
    try {
      trendCategories = await CategoriesService.trendCategories();
      developer.log('Fetched ${trendCategories.length} trend categories');
      notifyListeners();
    } catch (error) {
      print('Error fetching trend categories: $error');
      rethrow;
    }
  }

  // Method to fetch all data (both categories and trend categories)
  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      print('Starting to fetch all category data');
      await Future.wait([
        getCategoriesData(),
        getTrendCategoriesData(),
      ]);
      print('Successfully fetched all category data');
    } catch (e) {
      print('Error in fetchData: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to get courses for a specific category (lazy loading)
  Future<List<CourseModel>> getCoursesForCategory(int categoryId) async {
    if (categoryCourses.containsKey(categoryId)) {
      return categoryCourses[categoryId]!;
    }

    try {
      final courses = await CourseService.getAll(
        offset: 0,
        cat: categoryId.toString(),
      );
      categoryCourses[categoryId] = courses;
      return courses;
    } catch (e) {
      print('Error fetching courses for category $categoryId: $e');
      return [];
    }
  }
}
