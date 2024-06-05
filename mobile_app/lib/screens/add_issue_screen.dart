import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProblemScreen extends StatefulWidget {
  @override
  _AddProblemScreenState createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

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
          'title': '123 Main St', // Placeholder address
          'description': _descriptionController.text,
          'image': base64Image,
          'reportedBy': '60b8d295f3f1a2c70563cbbc', // Placeholder user ID
          'location': {
            'type': 'Point',
            'coordinates': [-73.856077, 40.848447] // Placeholder coordinates
          },
        }),
      );

      if (response.statusCode == 201) {
        // Issue successfully created
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Issue successfully created')),
        );
        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _image = null;
        });
      } else {
        // Error occurred
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a problem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Problem title*',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Problem description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  color: Colors.grey[200],
                  height: 150,
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),
              Container(
                color: Colors.amber,
                height: 150,
                child: Center(
                  child: Text(
                    'Map placeholder',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add cancel logic if needed
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Icon(Icons.cancel),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Icon(Icons.check),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
