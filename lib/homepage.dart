import 'package:carrentalapp/carinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _searchController = TextEditingController();

  @override
void initState() {
  super.initState();
  _searchController.addListener(() {
    setState(() {}); 
  });
}
  final List<String> filters = [
    "Economy Cars", "SUVs", "Sedans", "Luxury Cars", "Convertibles",
    "Sports Cars", "Electric Vehicles (EVs)", "Hybrids", "Minivans",
    "Pickup Trucks", "Vans (Commercial)", "Budget-Friendly",
    "Long-Term Rentals", "High Fuel Efficiency", "Automatic Transmission",
    "Manual Transmission", "7+ Seaters", "Apple CarPlay/Android Auto",
    "Advanced Safety Features", "Pet-Friendly", "Child Seat Ready",
    "Off-Road Capable", "Towing Available", "Handicap Accessible",
  ];

  int? _selectedFilterIndex;

  Future<List<Map<String, dynamic>>> _fetchCars() async {
    try {
      Query query = FirebaseFirestore.instance.collection('cars');

      if (_selectedFilterIndex != null) {
        query = query.where('filters', arrayContains: filters[_selectedFilterIndex!]);
      }else if (_searchController.text.trim().isNotEmpty) {
      // Search by car name or model
      query = 
      query.where('name', isGreaterThanOrEqualTo: _searchController.text.trim())
       .where('name', isLessThanOrEqualTo: _searchController.text.trim() + '\uf8ff');
    }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error fetching cars: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  "Zymo \nCar Rental",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search Car Model",
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: FilterChip(
                    label: Text(filters[index]),
                    selected: _selectedFilterIndex == index,
                    onSelected: (isSelected) {
                      setState(() {
                        _selectedFilterIndex = isSelected ? index : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchCars(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No cars available",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final car = snapshot.data![index];
                    return _buildCarCard(car);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Image.network(
              car['image'] ?? 'https://placehold.co/300x200?text=Car+Image',
              width: 150,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 150,
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.car_repair, size: 50),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car['name'] ?? 'Unnamed Vehicle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${car['pricePerDay']?.toStringAsFixed(2) ?? '0.00'}/day',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    car['description'] ?? 'No description available',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Carinfo(car: car),
                            ),
                          );
                        },
                        child: const Text(
                          "Rent",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: () async {
                          Map<String, dynamic> carData = {
                            'brand': car['brand'],
                            'model': car['model'],
                            'timestamp': FieldValue.serverTimestamp(),
                          };
    
                          try {
                            await FirebaseFirestore.instance
                                .collection("saved")
                                .add(carData);
                            print("Car saved successfully!");
                          } catch (e) {
                            print("Failed to save car: $e");
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
