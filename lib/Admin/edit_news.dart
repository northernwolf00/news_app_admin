import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class EditNews extends StatefulWidget {
  final String? newsId;
  final Map<String, dynamic>? existingData;

  EditNews({this.newsId, this.existingData});
  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<EditNews> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedFaculty;
  DateTime? _selectedDate;
  File? _image;
  String? _existingImageUrl;
   bool _isSaving = false;

  Future<void> _selectDateAndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }


  final _categories = [
    'Politics',
    'Sports',
    'Technology',
    'Health',
    'Business',
    'Science',
    'Entertainment',
    'Travel',
    'Education',
    'Environment',
  ];
  final _faculties = [
    'Computer Science and Information Technology',
    'Economics of Innovations',
    'Cyber-physical systems',
    'Biotechnology and Ecology',
    'Chemistry and Nanotechnology'
  ];

  @override
void initState() {
  super.initState();
  if (widget.existingData != null) {
    // Pre-fill fields with existing data for editing
    _titleController.text = widget.existingData?['title'] ?? '';
    _descriptionController.text = widget.existingData?['description'] ?? '';
    _selectedCategory = widget.existingData?['category'];
    _selectedFaculty = widget.existingData?['faculty'];

    // Handle the date conversion properly
    var dateData = widget.existingData?['date'];
    if (dateData is Timestamp) {
      _selectedDate = dateData.toDate();
    } else if (dateData is String) {
      try {
        _selectedDate = DateFormat("dd.MM.yyyy, HH:mm").parse(dateData);
      } catch (e) {
        print("Error parsing date: $e");
        _selectedDate = null; // Handle invalid date format
      }
    }

    _existingImageUrl = widget.existingData?['imageUrl'];
  }
}

  // Function to upload the image to GitHub
  Future<String?> _uploadImageToGitHub(File imageFile) async {
   const String token = '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'; // Replace with your GitHub token
  const String owner = 'northernwolf00'; // Replace with your GitHub username
    const String repo = 'image_upload'; // Replace with your repository name
    const String branch = 'main'; // Replace with your target branch

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final fileName = 'images/${path.basename(imageFile.path)}';

      final url = Uri.parse(
          'https://api.github.com/repos/$owner/$repo/contents/$fileName');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
        body: jsonEncode({
          'message': 'Upload image $fileName',
          'content': base64Image,
          'branch': branch,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['content']['download_url'];
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print('Error uploading image to GitHub: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveNews() async {
    
    if (_image == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    String? imageUrl = _existingImageUrl;
    setState(() {
      _isSaving = true; // Show the progress indicator
    });

    // Upload image to GitHub if a new image is selected
    if (_image != null) {
      try {
        imageUrl = await _uploadImageToGitHub(_image!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
      } catch (e) {
        print('Error during image upload: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }

    final formattedDate = _selectedDate != null
      ? DateFormat('dd.MM.yyyy, HH:mm').format(_selectedDate!)
      : null;

    final newsData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'faculty': _selectedFaculty,
      'date': formattedDate.toString(),
      'imageUrl': imageUrl,
    };

    try {
      if (widget.newsId != null) {
        // Update existing news
        await FirebaseFirestore.instance
            .collection('news')
            .doc(widget.newsId)
            .update(newsData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('News updated successfully')),
        );

      } else {
        // Add new news
        await FirebaseFirestore.instance.collection('news').add(newsData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('News added successfully')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print('Failed to save news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save news: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false; // Hide the progress indicator
      });
    }
  }

  // Future<void> _saveNews() async {

  //   String? imageUrl;
  //   if (_image == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please select an image')),
  //     );
  //     return;
  //   }

  //   // Upload image to GitHub
  //   try {
  //     imageUrl = await _uploadImageToGitHub(_image!);
  //     if (imageUrl == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to upload image')),
  //       );
  //       return;
  //     }
  //   } catch (e) {
  //     print('Error during image upload: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to upload image: $e')),
  //     );
  //     return;
  //   }

  //   // Save news data to Firestore
  //   try {
  //     await FirebaseFirestore.instance.collection('news').add({
  //       'title': _titleController.text,
  //       'description': _descriptionController.text,
  //       'category': _selectedCategory,
  //       'faculty': _selectedFaculty,
  //       'date': _selectedDate,
  //       'imageUrl': imageUrl,
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('News added successfully')),
  //     );
  //     Navigator.pop(context);
  //   } catch (e) {
  //     print('Failed to save news: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to save news: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add News')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              maxLines: null, // Allows multiline input
              keyboardType: TextInputType
                  .multiline, // Optimized keyboard for multiline input
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              scrollPhysics:
                  BouncingScrollPhysics(), // Enables smooth scrolling
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14,),
                          ),
                      
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(labelText: 'Category'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedFaculty,
              items: _faculties
                  .map((faculty) => DropdownMenuItem(
                        value: faculty,
                        child: Text(faculty,
                         overflow: TextOverflow.ellipsis,
                         style: TextStyle(fontSize: 14,),),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFaculty = value;
                });
              },
              decoration: InputDecoration(labelText: 'Faculty'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectDateAndTime,
              child: Text('Select Date and Time'),
            ),
            SizedBox(height: 10),
            if (_selectedDate != null)
              Text(
                'Selected Date: ${DateFormat('dd.MM.yyyy, HH:mm').format(_selectedDate!)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            else
              Text(
                'No date selected',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            SizedBox(height: 20),
            _image == null
                ? Text('No image selected')
                : Image.file(
                    _image!,
                    height: 150,
                  ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
           _isSaving
                ? CircularProgressIndicator() // Show the progress indicator when saving
                : ElevatedButton(
              onPressed: _saveNews,
              child: Text('Save News'),
            ),
          ],
        ),
      ),
    );
  }
}
