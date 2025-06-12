import 'package:carrentalapp/locationpickerpage.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class Carinfo extends StatefulWidget {
  final Map<String, dynamic> car;
  const Carinfo({super.key,required this.car});
  
  @override
  State<Carinfo> createState() => _CarinfoState();
}

class _CarinfoState extends State<Carinfo> {
  final _contactNo=TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car['name'] ?? 'Car Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image with error handling
            SizedBox(
              height: 450,
              width: double.infinity,
              child: Image.network(
                widget.car['image'] ?? 'https://placehold.co/600x400?text=No+Image',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.car_repair, size: 100),
                ),
              ),
            ),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Name
                  Text(
                    widget.car['name'] ?? 'Unnamed Vehicle',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    '\$${widget.car['pricePerDay']?.toString() ?? 'N/A'} per day',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),  
                  
                  const SizedBox(height: 16),
                  
                  // Divider
                  const Divider(),
                  
                  // Specifications
                  const Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Specification Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    children: [
                      _buildSpecItem('Brand', widget.car['brand']),
                      _buildSpecItem('Availability', widget.car['isAvailable'].toString()),
                      _buildSpecItem('Seats', widget.car['seat']?.toString()),
                      _buildSpecItem('Fuel Type', widget.car['fuelType']),
                    ],
                  ),
                  
                  const Divider(),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.car['description'] ?? 'No description available',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Rent Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                       _build_RentDialog();
                      },
                      child: const Text(
                        'Rent Now',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _build_RentDialog() async {
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text("Enter Details"),
            content: SizedBox(
              height: 400,
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _contactNo,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      helper: Row(
                        children: [
                        Icon(Icons.phone),
                        Text("Contact Number")
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _startDate == null
                        ? 'No start date selected'
                        : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}',
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      await _selectDate(
                        context,
                        isStartDate: true,
                        setDialogState: setDialogState,
                      );
                    },
                    child: const Text('Select Starting Date', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _endDate == null
                        ? 'No end date selected'
                        : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}',
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      await _selectDate(
                        context,
                        isStartDate: false,
                        setDialogState: setDialogState,
                      );
                    },
                    child: const Text('Select Ending Date', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      await _selectLocation(context);
                      setDialogState(() {}); // Rebuild if you want to show selected address
                    },
                    child: const Text('Select your location', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // Validation logic
                  if (_contactNo.text.isEmpty || _startDate == null || _endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please complete all fields")),
                    );
                    return;
                  }
                  Navigator.pop(context);
                },
                child: const Text("Pay"),
              ),
            ],
          );
        },
      );
    },
  );
}


Future<void> _selectLocation(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LocationPickerPage()),
  );

  if (result != null && result is LatLng) {
    print("Selected Location: ${result.latitude}, ${result.longitude}");
    
    try {
      List<Placemark>? placemarks = await placemarkFromCoordinates(
        result.latitude,
        result.longitude,
      );

      if (placemarks == null || placemarks.isEmpty) {
        print("No address found for these coordinates");
        return;
      }

      Placemark place = placemarks[0];
      String address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
      print(address);
    } catch (e) {
      print("Geocoding failed: $e");
    }
  }
}
  
Future<void> _selectDate(
  BuildContext context, {
  required bool isStartDate,
  required void Function(void Function()) setDialogState,
}) async {
  final DateTime initialDate = isStartDate
      ? (_startDate ?? DateTime.now())
      : (_endDate ?? (_startDate != null ? _startDate!.add(Duration(days: 1)) : DateTime.now().add(Duration(days: 1))));
  
  final DateTime firstDate = isStartDate
      ? DateTime.now()
      : (_startDate != null ? _startDate!.add(Duration(days: 1)) : DateTime.now());
  
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    setState(() {
      if (isStartDate) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });

    // Update the dialog UI too!
    setDialogState(() {});
  }
}

Widget _buildSpecItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}