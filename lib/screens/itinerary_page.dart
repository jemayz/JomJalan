import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/providers/itinerary_provider.dart';
import 'package:provider/provider.dart';

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the ItineraryProvider
    final itinerary = context.watch<ItineraryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Itinerary',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body:
          itinerary.spots.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Ionicons.map_outline, size: 80, color: subTextColor),
                    SizedBox(height: 16),
                    Text(
                      'Your itinerary is empty.',
                      style: TextStyle(fontSize: 18, color: subTextColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add spots from the Home page!',
                      style: TextStyle(fontSize: 16, color: subTextColor),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: itinerary.spots.length,
                itemBuilder: (context, index) {
                  final spot = itinerary.spots[index];
                  return Card(
                    color: secondaryBackgroundColor,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          spot.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        spot.name,
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        spot.location,
                        style: TextStyle(color: subTextColor),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Remove the spot from the itinerary
                          context.read<ItineraryProvider>().removeSpot(spot);
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
