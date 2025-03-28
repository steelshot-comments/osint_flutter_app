import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  Set<int> _selectedImages = {};
  bool _isSelectionMode = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _deleteImage(int index) {
  setState(() {
    _images.removeAt(index);
    _selectedImages.remove(index);
    _isSelectionMode = _selectedImages.isNotEmpty;
  });
}


  void _toggleSelection(int index) {
    setState(() {
      if (_selectedImages.contains(index)) {
        _selectedImages.remove(index);
      } else {
        _selectedImages.add(index);
      }
      _isSelectionMode = _selectedImages.isNotEmpty;
    });
  }

 void _deleteSelectedImages() {
  setState(() {
    _images = _images
        .asMap()
        .entries
        .where((entry) => !_selectedImages.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
    _selectedImages.clear();
    _isSelectionMode = false;
  });
}


  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    // appBar: _isSelectionMode
    //     ? AppBar(
    //         title: Text("${_selectedImages.length} selected"),
    //         actions: [
    //           IconButton(
    //             icon: Icon(Icons.delete),
    //             onPressed: _deleteSelectedImages,
    //           )
    //         ],
    //       )
    //     : null,
    // body:
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: Text("Upload Image"),
        ),
        _images.isNotEmpty
            ? SizedBox(
              height: 300,
                child: GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () => _toggleSelection(index),
                      onTap: _isSelectionMode
                          ? () => _toggleSelection(index)
                          : null,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_images[index], fit: BoxFit.cover),
                          if (_isSelectionMode &&
                              _selectedImages.contains(index))
                            Container(
                              color: Colors.black.withValues(alpha: 0.5),
                              child:
                                  Icon(Icons.check_circle, color: Colors.white),
                            ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _deleteImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("No file uploaded", style: TextStyle(fontSize: 16)),
              ),
      ],
    );
    // );
  }
}
