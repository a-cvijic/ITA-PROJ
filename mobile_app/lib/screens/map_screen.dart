import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../colors.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(46.5547, 15.6459);
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteSmoke,
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Find',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: AppColors.whisper,
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () {
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.charcoal,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home Screen'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Issue'),
              onTap: () {
                Navigator.pushNamed(context, '/add_problem');
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Chat with Representative'),
              onTap: () {
                Navigator.pushNamed(context, '/message');
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Manage Messages'),
              onTap: () {
                Navigator.pushNamed(context, '/admin_messages');
              },
            ),
          ],
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
            top: kToolbarHeight + -50,
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
            left: 16.0, // Move the floating button to the left
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_problem');
              },
              backgroundColor: AppColors.slateBlue,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? AppColors.whiteSmoke : Colors.black,
          backgroundColor: isSelected ? AppColors.slateBlue : AppColors.softSky,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          _selectCategory(category);
        },
        child: Text(category),
      ),
    );
  }
}
