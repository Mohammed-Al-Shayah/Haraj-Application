import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';

import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await apiClient.get(ApiEndpoints.categoriesHome);
      final list = _extractList(res);
      return list
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map && res['data'] is List) {
      return List<dynamic>.from(res['data'] as List);
    }
    if (res is List) {
      return List<dynamic>.from(res);
    }
    return <dynamic>[];
  }

  // @override
  // List<CategoryModel> getCategories() {
  //   return [

  //     CategoryModel(
  //       id: 1,
  //       title: 'Real Estate',
  //       iconPath: 'assets/icons/real_estate.svg',
  //       exclusiveOfferCover:
  //           'https://i.pinimg.com/736x/8d/59/99/8d59991ad833c66d1ae1578250b7129d.jpg',
  //       subCategories: [
  //         SubCategoryModel(
  //           title: 'Apartments for Sale',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Studio Apartments'),
  //             SubSubCategoryModel(title: '1-Bedroom Apartments'),
  //             SubSubCategoryModel(title: '2-Bedroom Apartments'),
  //             SubSubCategoryModel(title: 'Luxury Apartments'),
  //             SubSubCategoryModel(title: 'Penthouse'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Land for Rent',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Residential Land'),
  //             SubSubCategoryModel(title: 'Commercial Land'),
  //             SubSubCategoryModel(title: 'Agricultural Land'),
  //             SubSubCategoryModel(title: 'Industrial Land'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Houses for Sale',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Villas'),
  //             SubSubCategoryModel(title: 'Townhouses'),
  //             SubSubCategoryModel(title: 'Duplexes'),
  //             SubSubCategoryModel(title: 'Farm Houses'),
  //           ],
  //         ),
  //       ],
  //     ),
  //     CategoryModel(
  //       id: 2,
  //       title: 'Vehicles',
  //       iconPath: 'assets/icons/real_estate.svg',
  //       subCategories: [
  //         SubCategoryModel(
  //           title: 'Cars for Sale',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Sedans'),
  //             SubSubCategoryModel(title: 'SUVs'),
  //             SubSubCategoryModel(title: 'Hatchbacks'),
  //             SubSubCategoryModel(title: 'Luxury Cars'),
  //             SubSubCategoryModel(title: 'Electric Vehicles'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Motorcycles',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Sports Bikes'),
  //             SubSubCategoryModel(title: 'Cruisers'),
  //             SubSubCategoryModel(title: 'Scooters'),
  //             SubSubCategoryModel(title: 'Off-road Bikes'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Commercial Vehicles',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Trucks'),
  //             SubSubCategoryModel(title: 'Vans'),
  //             SubSubCategoryModel(title: 'Buses'),
  //             SubSubCategoryModel(title: 'Heavy Equipment'),
  //           ],
  //         ),
  //       ],
  //     ),
  //     CategoryModel(
  //       id: 3,
  //       title: 'Electronics',
  //       iconPath: 'assets/icons/real_estate.svg',
  //       exclusiveOfferCover:
  //           'https://i.pinimg.com/736x/8d/59/99/8d59991ad833c66d1ae1578250b7129d.jpg',
  //       subCategories: [
  //         SubCategoryModel(
  //           title: 'Mobile Phones',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Smartphones'),
  //             SubSubCategoryModel(title: 'Feature Phones'),
  //             SubSubCategoryModel(title: 'Refurbished Phones'),
  //             SubSubCategoryModel(title: 'Accessories'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Laptops & Computers',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Gaming Laptops'),
  //             SubSubCategoryModel(title: 'Ultrabooks'),
  //             SubSubCategoryModel(title: 'Desktops'),
  //             SubSubCategoryModel(title: 'Monitors'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Home Appliances',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'TVs'),
  //             SubSubCategoryModel(title: 'Refrigerators'),
  //             SubSubCategoryModel(title: 'Washing Machines'),
  //             SubSubCategoryModel(title: 'Air Conditioners'),
  //           ],
  //         ),
  //       ],
  //     ),
  //     CategoryModel(
  //       id: 4,
  //       title: 'Home & Garden',
  //       iconPath: 'assets/icons/real_estate.svg',
  //       subCategories: [
  //         SubCategoryModel(
  //           title: 'Furniture',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Sofas & Couches'),
  //             SubSubCategoryModel(title: 'Beds & Mattresses'),
  //             SubSubCategoryModel(title: 'Dining Sets'),
  //             SubSubCategoryModel(title: 'Office Furniture'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Appliances',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Kitchen Appliances'),
  //             SubSubCategoryModel(title: 'Cleaning Equipment'),
  //             SubSubCategoryModel(title: 'Home Comfort'),
  //             SubSubCategoryModel(title: 'Laundry Care'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Garden & Outdoor',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Patio Furniture'),
  //             SubSubCategoryModel(title: 'Grills & Outdoor Cooking'),
  //             SubSubCategoryModel(title: 'Gardening Tools'),
  //             SubSubCategoryModel(title: 'Plants & Seeds'),
  //           ],
  //         ),
  //       ],
  //     ),
  //     CategoryModel(
  //       id: 5,
  //       title: 'Jobs',
  //       iconPath: 'assets/icons/real_estate.svg',
  //       exclusiveOfferCover:
  //           'https://i.pinimg.com/736x/8d/59/99/8d59991ad833c66d1ae1578250b7129d.jpg',
  //       subCategories: [
  //         SubCategoryModel(
  //           title: 'Full-Time Jobs',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'IT & Software'),
  //             SubSubCategoryModel(title: 'Finance & Accounting'),
  //             SubSubCategoryModel(title: 'Healthcare'),
  //             SubSubCategoryModel(title: 'Engineering'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Part-Time Jobs',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Retail'),
  //             SubSubCategoryModel(title: 'Hospitality'),
  //             SubSubCategoryModel(title: 'Customer Service'),
  //             SubSubCategoryModel(title: 'Delivery'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Remote Jobs',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Content Writing'),
  //             SubSubCategoryModel(title: 'Graphic Design'),
  //             SubSubCategoryModel(title: 'Virtual Assistant'),
  //             SubSubCategoryModel(title: 'Online Tutoring'),
  //           ],
  //         ),
  //       ],
  //     ),
  //     CategoryModel(
  //       id: 6,
  //       title: 'Services',
  //       iconPath: 'assets/icons/real_estate.svg',
  //       subCategories: [
  //         SubCategoryModel(
  //           title: 'Home Services',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Cleaning'),
  //             SubSubCategoryModel(title: 'Plumbing'),
  //             SubSubCategoryModel(title: 'Electrical'),
  //             SubSubCategoryModel(title: 'Pest Control'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Automotive Services',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Car Repair'),
  //             SubSubCategoryModel(title: 'Car Wash'),
  //             SubSubCategoryModel(title: 'Towing'),
  //             SubSubCategoryModel(title: 'Tire Services'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Professional Services',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Legal Services'),
  //             SubSubCategoryModel(title: 'Accounting'),
  //             SubSubCategoryModel(title: 'Consulting'),
  //             SubSubCategoryModel(title: 'Photography'),
  //           ],
  //         ),
  //       ],
  //     ),
  //     CategoryModel(
  //       id: 7,
  //       title: 'Fashion',
  //       iconPath: 'assets/icons/real_estate.svg',
  //       exclusiveOfferCover:
  //           'https://i.pinimg.com/736x/8d/59/99/8d59991ad833c66d1ae1578250b7129d.jpg',
  //       subCategories: [
  //         SubCategoryModel(
  //           title: 'Clothing',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: "Men's Clothing"),
  //             SubSubCategoryModel(title: "Women's Clothing"),
  //             SubSubCategoryModel(title: "Kids' Clothing"),
  //             SubSubCategoryModel(title: 'Sportswear'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Accessories',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: 'Watches'),
  //             SubSubCategoryModel(title: 'Jewelry'),
  //             SubSubCategoryModel(title: 'Bags'),
  //             SubSubCategoryModel(title: 'Sunglasses'),
  //           ],
  //         ),
  //         SubCategoryModel(
  //           title: 'Footwear',
  //           subSubCategories: [
  //             SubSubCategoryModel(title: "Men's Shoes"),
  //             SubSubCategoryModel(title: "Women's Shoes"),
  //             SubSubCategoryModel(title: 'Sports Shoes'),
  //             SubSubCategoryModel(title: 'Sandals'),
  //           ],
  //         ),
  //       ],
  //     ),

  //   ];
  // }
}
