import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stockniscala/pages/menu/InputStock.dart';

class InputStockResultPage extends StatefulWidget {
  final List<SelectedIngredient> selectedIngredients;

  InputStockResultPage({required this.selectedIngredients});

  @override
  _InputStockResultPageState createState() => _InputStockResultPageState();
}

class _InputStockResultPageState extends State<InputStockResultPage> {
  File? _image;

  Future<void> _getImageFromCamera() async {
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveStock() async {
    final CollectionReference inputStockCollection =
    FirebaseFirestore.instance.collection('input_stock');

    // Upload image to Firebase Storage
    if (_image != null) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference =
      FirebaseStorage.instance.ref().child('stock_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the uploaded image URL
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Save photo, selected ingredients, and quantity data to input_stock collection
      await inputStockCollection.add({
        'image': imageUrl,
        'ingredients': widget.selectedIngredients
            .map((ingredient) => {
          'name': ingredient.name,
          'quantity': ingredient.quantity,
        })
            .toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stock saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Stock Result'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Ingredients:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.selectedIngredients.length,
              itemBuilder: (context, index) {
                final selectedIngredient = widget.selectedIngredients[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.brown,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      selectedIngredient.name,
                      style: TextStyle(fontSize: 16.0, color: Colors.brown),
                    ),
                    subtitle: Text(
                      'Quantity: ${selectedIngredient.quantity}',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            if (_image != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImage(imageFile: _image!),
                    ),
                  );
                },
                child: Hero(
                  tag: 'image',
                  child: Container(
                    width: double.infinity,
                    height: 200.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                      image: DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _getImageFromCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.brown,
                  ),
                  child: Text('Take Picture'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _getImageFromGallery();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.brown,
                  ),
                  child: Text('Choose Picture'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveStock();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown,
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text('Save Stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;

  const FullScreenImage({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 2.0,
          child: Hero(
            tag: 'image',
            child: Image.file(imageFile),
          ),
        ),
      ),
    );
  }
}
