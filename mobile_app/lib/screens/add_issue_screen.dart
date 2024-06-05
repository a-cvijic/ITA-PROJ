import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import '../colors.dart';

class AddProblemScreen extends StatefulWidget {
  @override
  _AddProblemScreenState createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  final LatLng _initialPosition = LatLng(46.5547, 15.6459); // Maribor, Slovenia
  LatLng _selectedPosition = LatLng(46.5547, 15.6459); // Maribor, Slovenia
  GoogleMapController? _mapController;

  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyD1TDOxHVQqnPujrrEx7F1tUZBQf-lq_ss');

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      final String base64Image = base64Encode(await _image!.readAsBytes());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/issues'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'image': base64Image,
          'reportedBy': '60b8d295f3f1a2c70563cbbc', // Placeholder user ID
          'location': {
            'type': 'Point',
            'coordinates': [
              _selectedPosition.longitude,
              _selectedPosition.latitude
            ]
          },
        }),
      );

      if (response.statusCode == 201) {
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Issue successfully created')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create issue')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and add an image')),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _image = null;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    final response = await places.searchByText(_searchController.text);
    if (response.status == 'OK' && response.results.isNotEmpty) {
      final place = response.results.first;
      final location =
          LatLng(place.geometry!.location.lat, place.geometry!.location.lng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(location));
      setState(() {
        _selectedPosition = location;
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report an Issue'),
        backgroundColor: AppColors.slateBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTitleField(),
                  SizedBox(height: 16),
                  _buildDescriptionField(),
                  SizedBox(height: 16),
                  _buildImagePicker(),
                  SizedBox(height: 16),
                  _buildSearchField(),
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('problemLocation'),
                  position: _selectedPosition,
                ),
              },
              onTap: _onMapTap,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        backgroundColor: AppColors.slateBlue,
        child: Icon(Icons.send),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title*',
        labelStyle: TextStyle(color: AppColors.slateBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.slateBlue),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description*',
        labelStyle: TextStyle(color: AppColors.slateBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.slateBlue),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      maxLines: 6,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.slateBlue),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        height: 150,
        child: Center(
          child: _image == null
              ? Icon(Icons.camera_alt, size: 50, color: AppColors.slateBlue)
              : Image.file(_image!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search location',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.slateBlue),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: AppColors.slateBlue),
          onPressed: _searchLocation,
        ),
      ],
    );
  }
}
