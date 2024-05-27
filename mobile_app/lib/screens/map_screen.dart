import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final LatLng _center = const LatLng(46.5547, 15.6459);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Find',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
          ),
          Positioned(
            top: kToolbarHeight - 50,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton('All'),
                  _buildCategoryButton('Infrastructure'),
                  _buildCategoryButton('Environment'),
                  _buildCategoryButton('Safety'),
                  _buildCategoryButton('Community'),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                // Add the action later
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Text color
          backgroundColor: Colors.grey[200], // Background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          // Add the action later
        },
        child: Text(text),
      ),
    );
  }
}
