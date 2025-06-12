import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Savedpage extends StatefulWidget {
  const Savedpage({super.key});

  @override
  State<Savedpage> createState() => _SavedpageState();
}

class _SavedpageState extends State<Savedpage> {
  List<Map<String, dynamic>> savedCars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSavedCars();
  }

  Future<void> _getSavedCars() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
        .collection('saved')
        .get();
      setState(() {
        savedCars = snapshot.docs.map((doc) => {
        ...doc.data(), // Spread all document fields
        'documentId': doc.id, // Add the document ID
      }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading saved cars: $e')),
      );
    }
  }

  Future<void> _removeCar(String documentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
        .collection('saved')
        .doc(documentId)
        .delete();

      await _getSavedCars(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing car: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Cars"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedCars.isEmpty
              ? const Center(child: Text('No saved cars yet'))
              : ListView.builder(
                  itemCount: savedCars.length,
                  itemBuilder: (context, index) {
                    final car = savedCars[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: car['image'] != null
                            ? Image.network(car['image'], width: 50)
                            : const Icon(Icons.car_rental),
                        title: Text(car['model'] ?? 'Unnamed Car'),
                        subtitle: Text(
                            '${car['brand'] ?? 'N/A'} Brand'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeCar(car['documentId']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}