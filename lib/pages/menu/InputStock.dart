import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockniscala/pages/menu/AddNewStock.dart';
import 'package:stockniscala/pages/menu/InputStockResult.dart';

class Ingredient {
  final String name;

  Ingredient({required this.name});
}

class SelectedIngredient {
  final String name;
  final int quantity;

  SelectedIngredient({required this.name, required this.quantity});
}

class InputStockPage extends StatefulWidget {
  @override
  _InputStockPageState createState() => _InputStockPageState();
}

class _InputStockPageState extends State<InputStockPage> {
  final TextEditingController _quantityController = TextEditingController();
  String? selectedStock;
  int? quantity;
  List<Ingredient> ingredientList = [];
  Map<String, int> ingredientQuantities = {};
  List<SelectedIngredient> selectedIngredients = [];

  Future<void> _saveStock() async {
    if (selectedStock != null && quantity != null && quantity! > 0) {
      try {
        final CollectionReference ingredientsRef =
        FirebaseFirestore.instance.collection('ingredient');

        final QuerySnapshot snapshot = await ingredientsRef
            .where('name', isEqualTo: selectedStock)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final DocumentSnapshot doc = snapshot.docs.first;
          final String docId = doc.id;
          final int previousQuantity =
              (doc.data() as Map<String, dynamic>)['quantity'] as int? ?? 0;

          await ingredientsRef.doc(docId).update({
            'quantity': previousQuantity + (quantity ?? 0),
          });

          ingredientQuantities[selectedStock!] =
              previousQuantity + (quantity ?? 0);
        } else {
          await ingredientsRef.add({
            'name': selectedStock,
            'quantity': quantity,
          });

          ingredientQuantities[selectedStock!] = quantity!;
        }

        setState(() {
          selectedStock = null;
          _quantityController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock saved successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save stock. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _fetchIngredients() async {
    try {
      final CollectionReference ingredientsRef =
      FirebaseFirestore.instance.collection('ingredient');

      final QuerySnapshot snapshot = await ingredientsRef.get();

      final List<Ingredient> ingredients = snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String?;
        final quantity = data['quantity'] as int?;
        if (name != null && quantity != null) {
          ingredientQuantities[name] = quantity;
        }
        return Ingredient(name: name ?? '');
      })
          .toList();

      setState(() {
        ingredientList = ingredients;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch ingredients. Please try again.'),
        ),
      );
    }
  }

  void _removeSelectedIngredient(int index) {
    setState(() {
      final SelectedIngredient removedIngredient =
      selectedIngredients.removeAt(index);
      // Kurangi stok pada koleksi berdasarkan quantity yang dihapus
      if (ingredientQuantities.containsKey(removedIngredient.name)) {
        ingredientQuantities[removedIngredient.name] =
            ingredientQuantities[removedIngredient.name]! -
                removedIngredient.quantity;

        final CollectionReference ingredientsRef =
        FirebaseFirestore.instance.collection('ingredient');

        ingredientsRef
            .where('name', isEqualTo: removedIngredient.name)
            .limit(1)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final DocumentSnapshot doc = snapshot.docs.first;
            final String docId = doc.id;
            final int previousQuantity =
                (doc.data() as Map<String, dynamic>)['quantity'] as int? ?? 0;

            ingredientsRef.doc(docId).update({
              'quantity': previousQuantity - removedIngredient.quantity,
            }).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ingredient removed successfully!'),
                ),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Failed to remove selected ingredient. Please try again.'),
                ),
              );
            });
          }
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to remove selected ingredient. Please try again.'),
            ),
          );
        });
      }
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to finish?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _finishInputStock();
              },
            ),
          ],
        );
      },
    );
  }

  void _finishInputStock() {
    // Process the selected ingredients and do any necessary tasks
    // when the input stock is finished

    // Clear the selected ingredients list and ingredient quantities
    selectedIngredients.clear();
    ingredientQuantities.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Input stock finished!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Stock'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStock,
              decoration: InputDecoration(
                labelText: 'Select Stock',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  selectedStock = value;
                });
              },
              items: ingredientList.map((ingredient) {
                return DropdownMenuItem<String>(
                  value: ingredient.name,
                  child: Text(ingredient.name),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                quantity = int.tryParse(value);
              },
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedStock = null;
                      _quantityController.clear();
                    });
                  },
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (selectedStock != null && quantity != null) {
                        final selectedIngredient = SelectedIngredient(
                          name: selectedStock!,
                          quantity: quantity!,
                        );
                        selectedIngredients.add(selectedIngredient);
                      }
                      _saveStock();
                    });
                  },
                  child: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewStockPage()),
                );
              },
              child: Text('Add New Stock'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Selected Ingredients:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: selectedIngredients.length,
              itemBuilder: (context, index) {
                final selectedIngredient = selectedIngredients[index];
                return ListTile(
                  title: Text(selectedIngredient.name),
                  subtitle: Text('Quantity: ${selectedIngredient.quantity}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _removeSelectedIngredient(index);
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: selectedIngredients.isEmpty ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputStockResultPage(selectedIngredients: selectedIngredients),
                  ),
                );
              },
              child: Text('Selesai'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
