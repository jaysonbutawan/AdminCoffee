// lib/controller/coffee_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import '../services/api_coffee_services.dart';
import '../../model/coffee.dart';
class CoffeeController extends GetxController {
  // ✅ Observable variables
  var coffeeList = <Coffee>[].obs;
  var isLoading = false.obs;
  String adminId = ""; // optional: set this somewhere globally

  // ✅ Add Coffee
  Future<void> addCoffee(
    String name,
    String description,
    double price,
    String category,
    String aid,
    File image,
  ) async {
    try {
      final result = await ApiCoffeeServices.addCoffee(
        name,
        description,
        category,
        price,
        aid,
        image.path,
      );

      if (result["coffee_id"] != null) {
        print("Coffee added successfully: ${result["coffee_id"]}");
        // Optionally refetch list
        await fetchAllCoffees(aid);
      } else {
        print("Failed to add coffee: ${result["error"]}");
      }
    } catch (e) {
      print("Error adding coffee: $e");
    }
  }

Future<void> fetchAllCoffees(String aid) async {
  try {
    isLoading(true);
    final result = await ApiCoffeeServices.getAllCoffees(aid);

    print("📡 [CoffeeController] Result data: $result");

    // Adjust based on actual JSON structure
    final data = result["data"]?["coffees"] ?? result["coffees"];

    if (data is List) {
      coffeeList.assignAll(
        data.map((e) => Coffee.fromJson(e as Map<String, dynamic>)).toList(),
      );
      print("✅ Loaded ${coffeeList.length} coffees");
    } else {
      coffeeList.clear();
      print("⚠️ No coffees found for admin $aid");
    }
  } catch (e, st) {
    print("❌ Error fetching coffees: $e\n$st");
  } finally {
    isLoading(false);
  }
}




  Future<int> fetchCoffeeCount(String aid) async {
    try {
      final result = await ApiCoffeeServices.coffeeCount(aid);
      if (result["count"] != null) {
        return result["count"];
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
