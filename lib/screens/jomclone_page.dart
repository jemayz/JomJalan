import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/models/itinerary_model.dart';
import 'package:jomjalan/main.dart'; // For colors

class JomClonePage extends StatefulWidget {
  const JomClonePage({Key? key}) : super(key: key);

  @override
  _JomClonePageState createState() => _JomClonePageState();
}

class _JomClonePageState extends State<JomClonePage> {
  // --- This is your "database" of shared itineraries ---
  // In a real app, this would come from your server
  final List<Itinerary> allItineraries = [
    Itinerary(
      id: 'pah1',
      title: '17 Things To Do In Cameron Highlands',
      state: 'Pahang',
      author: '@maiSinggah',
      duration: '3 Days',
      spots: 12,
      clones: 128,
      imageUrl:
          'https://res.klook.com/image/upload/q_85/c_fill,w_650,h_345/v1637055583/blog/tc3h1hj1hcylojhf5gzx.jpg',
    ),
    Itinerary(
      id: 'per2',
      title: 'Explore Perak-Ipoh Hidding Valley',
      state: 'Ipoh',
      author: '@IniPekanOrangHensem',
      duration: '2 Days',
      spots: 8,
      clones: 92,
      imageUrl:
          "https://thumbs.dreamstime.com/b/tasik-cermin-ipoh-perak-malaysia-232651537.jpg",
    ),
    Itinerary(
      id: 'kl1',
      title: '14 Tempat Menarik Yang Percuma di Kuala Lumpur',
      state: 'Kuala Lumpur',
      author: '@KLFoodie',
      duration: '1 Day',
      spots: 7,
      clones: 215,
      imageUrl:
          'https://theinspirasi.com/wp-content/uploads/2024/05/14-Tempat-Menarik-Yang-Percuma-di-Kuala-Lumpur.jpg',
    ),
    Itinerary(
      id: 'm1',
      title: 'Jelajah Melaka Seperti Pahlawan',
      state: 'Melaka',
      author: '@matSilau',
      duration: '2 Days',
      spots: 10,
      clones: 76,
      imageUrl:
          "https://images.says.com/uploads/story/cover_image/29806/8b84.jpg",
    ),
  ];

  // List of states for the TabBar
  final List<String> _malaysianStates = [
    'All',
    'Kuala Lumpur',
    'Selangor',
    'Perak',
    'Penang',
    'Johor',
    'Sabah',
    'Sarawak',
    'Melaka',
    'Negeri Sembilan',
    'Kedah',
    'Pahang',
    'Terengganu',
    'Kelantan',
    'Perlis',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _malaysianStates.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Explore Plans",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          // The scrollable TabBar for states
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: primaryGreen,
            labelColor: primaryGreen,
            unselectedLabelColor: Colors.grey,
            tabAlignment: TabAlignment.start,
            tabs: _malaysianStates.map((state) => Tab(text: state)).toList(),
          ),
        ),
        body: TabBarView(
          // Create a list page for each state
          children:
              _malaysianStates.map((state) {
                // Filter the itineraries for the selected state
                final List<Itinerary> filteredList =
                    allItineraries.where((it) {
                      if (state == 'All') return true;
                      return it.state == state;
                    }).toList();

                return _buildItineraryList(filteredList, state);
              }).toList(),
        ),
      ),
    );
  }

  /// Builds the list of itinerary cards for a given state
  Widget _buildItineraryList(List<Itinerary> itineraries, String state) {
    if (itineraries.isEmpty) {
      return Center(
        child: Text(
          "No shared plans for $state... yet!",
          style: const TextStyle(color: subTextColor, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: itineraries.length,
      itemBuilder: (context, index) {
        return _ItineraryCard(itinerary: itineraries[index]);
      },
    );
  }
}

/// --- The Card Widget for each Itinerary ---
class _ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;
  const _ItineraryCard({Key? key, required this.itinerary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: secondaryBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Image.network(
            itinerary.imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  itinerary.title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Author
                Text(
                  "by ${itinerary.author}",
                  style: const TextStyle(
                    color: subTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats (Duration, Spots, Clones)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatChip(Ionicons.time_outline, itinerary.duration),
                    _buildStatChip(
                      Ionicons.location_outline,
                      "${itinerary.spots} Spots",
                    ),
                    _buildStatChip(
                      Ionicons.git_compare_outline,
                      "${itinerary.clones} Clones",
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // "JomClone" Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement clone logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${itinerary.title} cloned!"),
                          backgroundColor: accentColor,
                        ),
                      );
                    },

                    label: const Text(
                      "JomClone this Plan!",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget for the small stat chips
  Widget _buildStatChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: textColor),
      label: Text(
        label,
        style: const TextStyle(color: textColor, fontSize: 12),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
    );
  }
}
