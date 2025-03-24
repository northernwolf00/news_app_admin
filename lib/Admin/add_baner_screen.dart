import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AddBannerScreen extends StatefulWidget {
  @override
  _AddBannerScreenState createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<String?> _uploadImageToGitHub(File imageFile) async {
   const String token = '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'; // Replace with your GitHub token
  const String owner = 'northernwolf00';
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

//   Future<String?> _uploadImageToGitHub(File imageFile) async {
//   const String token = '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'; // Replace with your GitHub token
//   const String owner = 'northernwolf00';
//   const String repo = 'image_upload';
//   const String branch = 'main';

//   try {
//     final imageBytes = await imageFile.readAsBytes();
//     final base64Image = base64Encode(imageBytes);
//     final fileName = 'images/${path.basename(imageFile.path)}';

//     Uri url = Uri.parse(
//         'https://api.github.com/repos/$owner/$repo/contents/$fileName?ref=$branch');

//     final response = await http.put(
//       url,
//       headers: {
//         'Authorization': 'token $token',
//         'Accept': 'application/vnd.github.v3+json',
//       },
//       body: jsonEncode({
//         'message': 'Upload image $fileName',
//         'content': base64Image,
//         'branch': branch,
//       }),
//     );

//     // Handle redirect (307)
//     if (response.statusCode == 307) {
//       final newUrl = response.headers['location'];
//       if (newUrl != null) {
//         url = Uri.parse(newUrl);
//         final redirectResponse = await http.put(
//           url,
//           headers: {
//             'Authorization': 'token $token',
//             'Accept': 'application/vnd.github.v3+json',
//           },
//           body: jsonEncode({
//             'message': 'Upload image $fileName',
//             'content': base64Image,
//             'branch': branch,
//           }),
//         );
//         if (redirectResponse.statusCode == 201) {
//           final responseData = jsonDecode(redirectResponse.body);
//           return responseData['content']['html_url']; // Use html_url instead of download_url
//         }
//       }
//     } else if (response.statusCode == 201) {
//       final responseData = jsonDecode(response.body);
//       return responseData['content']['html_url'];
//     } else {
//       print('Failed to upload image: ${response.statusCode}');
//       print(response.body);
//       return null;
//     }
//   } catch (e) {
//     print('Error uploading image to GitHub: $e');
//     return null;
//   }
// }


  Future<void> _uploadBanners() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select images')),
      );
      return;
    }

    try {
      for (var image in _images) {
        final imageUrl = await _uploadImageToGitHub(image);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${path.basename(image.path)}')),
          );
          return;
        }

        // Save the uploaded image URL to Firestore
        await FirebaseFirestore.instance.collection('banners').add({
          'imageUrl': imageUrl,
          'uploadedAt': Timestamp.now(),
        });

        print('Image uploaded and saved to Firestore: $imageUrl');
      }

      setState(() {
        _images.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banners uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading banners: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload banners: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Banners'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('Select Images'),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _images.isEmpty
                ? Center(child: Text('No images selected'))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Image.file(_images[index], fit: BoxFit.cover);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _uploadBanners,
              child: Text('Upload Banners'),
            ),
          ),
        ],
      ),
    );
  }
}
