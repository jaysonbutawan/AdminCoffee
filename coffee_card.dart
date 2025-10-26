import 'package:flutter/material.dart';
import 'package:admincoffee/model/coffee.dart';
import '../services/api_coffee_services.dart';

class CompactCoffeeCard extends StatelessWidget {
  final Coffee coffee;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const CompactCoffeeCard({
    super.key,
    required this.coffee,
    this.onDelete,
    this.onEdit,
  });

  Future<void> _deleteCoffee(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Archive Coffee",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
        ),
        content: Text(
          "Are you sure you want to archive '${coffee.name}'? This item will be removed from the active list.",
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Archive", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Assuming ApiCoffeeServices.deleteCoffee handles the archive action
        final result = await ApiCoffeeServices.deleteCoffee(coffee.id); 
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Coffee archived successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        if (onDelete != null) onDelete!();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = "\$${coffee.price.toStringAsFixed(2)}";
    const double cardRadius = 15.0;
    
    // Convert the card to a Column-based design for grid layout
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      margin: const EdgeInsets.all(8.0),
      color: Colors.white, // Light background color for the card
      
      child: InkWell(
        // Optional: Add an onTap action here if the entire card should be clickable
        onTap: onEdit, 
        borderRadius: BorderRadius.circular(cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image and Overlayed Buttons (using Stack)
            Stack(
              children: [
                // Image Container
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(cardRadius)),
                  child: Container(
                    height: 120, // Fixed height for the image area
                    width: double.infinity,
                    color: Colors.grey[200], // Placeholder color
                    child: (coffee.image != null && coffee.image!.isNotEmpty)
                        ? Image.memory(
                            coffee.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          )
                        : const Center(child: Icon(Icons.coffee, color: Colors.grey, size: 40)),
                  ),
                ),
                
                // Edit Button (Top Left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit, size: 18, color: Color(0xFF5E503F)), // Edit icon
                    ),
                  ),
                ),
                
                // Delete Button (Top Right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _deleteCoffee(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red[100], // Light red background for delete
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.red), // Delete icon
                    ),
                  ),
                ),
              ],
            ),
            
            // 2. Text Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coffee Name
                  Text(
                    coffee.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // Coffee Price
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  // NOTE: The description is typically removed from a compact grid card. 
                  // If you need it, you can re-add it here.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}