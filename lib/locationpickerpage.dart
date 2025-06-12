import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(27.7172, 85.3240), 
          maxZoom: 20.0,
          onTap: (tapPosition, latlng) {
            setState(() {
              _pickedLocation = latlng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          if (_pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                width: 80,
                height: 80,
                point: _pickedLocation!,
                child: Icon(Icons.location_pin, size: 40, color: Colors.red),
              )

              ],
            ),
        ],
      ),
      floatingActionButton: _pickedLocation != null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context, _pickedLocation),
              label: const Text("Select"),
              icon: const Icon(Icons.check),
            )
          : null,
    );
  }
}
