import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController _quantityController = TextEditingController();
  String? selectedMenu;
  int? quantity;

  Future<void> _saveSale() async {
    if (selectedMenu != null && quantity != null && quantity! > 0) {
      try {
        final CollectionReference salesRef = FirebaseFirestore.instance.collection(
            'sales_${DateTime.now().toString().split(' ')[0]}');

        await salesRef.add({
          'menu': selectedMenu,
          'quantity': quantity,
          'timestamp': FieldValue.serverTimestamp(),
        });

        final CollectionReference menusRef = FirebaseFirestore.instance.collection('menus');
        final QuerySnapshot snapshot = await menusRef
            .where('name', isEqualTo: selectedMenu)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final DocumentSnapshot menuDoc = snapshot.docs.first;
          final String menuDocId = menuDoc.id;

          final List<dynamic> ingredients = (menuDoc.data() as Map<String, dynamic>)['ingredients'];

          for (int i = 0; i < ingredients.length; i++) {
            final Map<String, dynamic> ingredient = ingredients[i];
            final String ingredientName = ingredient['ingredientName'];
            final int ingredientQuantity = ingredient['quantity'];

            final CollectionReference ingredientsRef = FirebaseFirestore.instance.collection('ingredients');
            final QuerySnapshot ingredientSnapshot = await ingredientsRef
                .where('name', isEqualTo: ingredientName)
                .limit(1)
                .get();

            if (ingredientSnapshot.docs.isNotEmpty) {
              final DocumentSnapshot ingredientDoc = ingredientSnapshot.docs.first;
              final String ingredientDocId = ingredientDoc.id;

              final int previousQuantity = (ingredientDoc.data() as Map<String, dynamic>)['quantity'];

              await ingredientsRef.doc(ingredientDocId).update({
                'quantity': previousQuantity - (ingredientQuantity * quantity!),
              });
            }
          }
        }

        _quantityController.clear();
        setState(() {
          quantity = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sale added successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add sale. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Menu:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('menus').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Loading...');
                }

                final List<DropdownMenuItem<String>> menuItems = snapshot.data!.docs.map((menuDoc) {
                  final data = menuDoc.data() as Map<String, dynamic>;
                  final name = data['name'] as String?;
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name ?? ''),
                  );
                }).toList();

                return DropdownButtonFormField<String>(
                  value: selectedMenu,
                  decoration: InputDecoration(
                    labelText: 'Select Menu',
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedMenu = value;
                    });
                  },
                  items: menuItems,
                );
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Enter Quantity:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
              ),
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value);
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveSale,
              child: Text('Add Sale'),
            ),
          ],
        ),
      ),
    );
  }
}
