import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockniscala/pages/menu/addMenu.dart';
import 'package:stockniscala/pages/menu/test.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  Future<List<String>> fetchMenuItems() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('menus')
        .get();

    final List<String> menuItems = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['name'] as String;
    }).toList();

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchMenuItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final menuItems = snapshot.data!;
                  return ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return ListTile(
                        title: Text(item),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMenuPage()),
              );
            },
            child: Text("Add Menu"),
          ),
        ],
      ),
    );
  }
}


