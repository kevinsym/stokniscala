import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuDetailPage extends StatefulWidget {
  final String menuName;

  const MenuDetailPage({Key? key, required this.menuName}) : super(key: key);

  @override
  _MenuDetailPageState createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  List<Map<String, dynamic>> _ingredients = [];

  @override
  void initState() {
    super.initState();
    fetchMenuIngredients();
  }

  Future<void> fetchMenuIngredients() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('menus')
        .where('name', isEqualTo: widget.menuName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final menuData = snapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        _ingredients = menuData['ingredients'] as List<Map<String, dynamic>>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuName),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ingredients:",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _ingredients.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> ingredient = _ingredients[index];
                  String name = ingredient['ingredientName'];
                  int quantity = ingredient['quantity'];

                  return ListTile(
                    title: Text('$name - $quantity'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
