import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/guest_service/course_service.dart';


// @override
// void initState() {
//   super.initState();
//
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     Provider.of<CourseDataManager>(context, listen: false).getData();
//   });
// }

class CourseDataManagerProvider extends ChangeNotifier {
  bool isLoadingData = false;

  // Data variables
  bool isLoadingFeaturedListData = false;
  List<CourseModel> featuredListData = [];

  bool isLoadingNewsetListData = false;
  List<CourseModel> newsetListData = [];

  bool isLoadingBestRatedListData = false;
  List<CourseModel> bestRatedListData = [];

  bool isLoadingBestSellingListData = false;
  List<CourseModel> bestSellingListData = [];

  bool isLoadingDiscountListData = false;
  List<CourseModel> discountListData = [];

  bool isLoadingFreeListData = false;
  List<CourseModel> freeListData = [];

  bool isLoadingBundleData = false;
  List<CourseModel> bundleData = [];

  // Method to get all course data
  Future<void> getData() async {
    try {
      isLoadingData = true;


      isLoadingFeaturedListData = true;
      isLoadingNewsetListData = true;
      isLoadingBundleData = true;
      isLoadingBestRatedListData = true;
      isLoadingBestSellingListData = true;
      isLoadingDiscountListData = true;
      isLoadingFreeListData = true;

      notifyListeners(); // Notify UI once

      final results = await Future.wait([
        CourseService.featuredCourse(),
        CourseService.getAll(offset: 0, sort: 'newest'),
        CourseService.getAll(offset: 0, sort: 'best_rates'),
        CourseService.getAll(offset: 0, sort: 'bestsellers'),
        CourseService.getAll(offset: 0, discount: true),
        CourseService.getAll(offset: 0, free: true),
        CourseService.getAll(offset: 0, bundle: true),
      ]);

      // Assign fetched results
      featuredListData = results[0];
      newsetListData = results[1];
      bestRatedListData = results[2];
      bestSellingListData = results[3];
      discountListData = results[4];
      freeListData = results[5];
      bundleData = results[6];
    } catch (error) {
      // Handle errors if needed
    } finally {
      isLoadingData = false;

      // Set all loading states to false and notify
      isLoadingFeaturedListData = false;
      isLoadingNewsetListData = false;
      isLoadingBundleData = false;
      isLoadingBestRatedListData = false;
      isLoadingBestSellingListData = false;
      isLoadingDiscountListData = false;
      isLoadingFreeListData = false;

      notifyListeners();
    }
  }



}