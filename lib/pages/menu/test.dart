import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

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
      body: FutureBuilder<List<String>>(
        future: fetchMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while waiting for data
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
      )
      );

  }

}


