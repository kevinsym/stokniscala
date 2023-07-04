import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockniscala/pages/menu/addMenu.dart';
import 'package:stockniscala/pages/menu/menuDetailPage.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late Stream<List<String>>? menuItemsStream;

  @override
  void initState() {
    super.initState();
    menuItemsStream = FirebaseFirestore.instance
        .collection('menus')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] as String;
      }).toList();
    });
  }

  Future<void> deleteMenu(String menuName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Menu'),
          content: const Text('Are you sure you want to delete this menu?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('menus')
                    .where('name', isEqualTo: menuName)
                    .get()
                    .then((snapshot) {
                  snapshot.docs.first.reference.delete();
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: menuItemsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final menuItems = snapshot.data!;
                    if (menuItems.isEmpty) {
                      return const Center(child: Text('No menu items available'));
                    }
                    return ListView.builder(
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return Card(
                          child: ListTile(
                            title: Text(item),
                            leading: const Icon(Icons.fastfood),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuDetailPage(menuName: item),
                                ),
                              );
                            },
                            onLongPress: () {
                              deleteMenu(item);
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.brown, // Warna coklat
              ),
              child: const Text("Add Menu"),
            ),
          ],
        ),
      ),
    );
  }
}
