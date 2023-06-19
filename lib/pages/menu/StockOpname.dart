import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockniscala/pages/menu/StockOpnameResult.dart';

class StockOpnamePage extends StatefulWidget {
  @override
  _StockOpnamePageState createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends State<StockOpnamePage> {
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    fetchStockItems();
  }

  Future<void> fetchStockItems() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('ingredient').get();

      final List<Item> fetchedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Item(
          id: doc.id,
          name: data['name'],
          quantity: data['quantity'],
        );
      }).toList();

      setState(() {
        items = fetchedItems;
      });
    } catch (error) {
      print('Failed to fetch stock items: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Opname'),
        backgroundColor: Colors.brown,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final bool isEdited = item.quantity != item.newQuantity;

          return ListTile(
            title: Text(item.name),
            subtitle: item.isEditing
                ? TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'New Quantity'),
              onChanged: (value) {
                setState(() {
                  item.newQuantity = int.tryParse(value) ?? 0;
                });
              },
            )
                : Text('Quantity: ${item.quantity}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  item.isEditing = true;
                });
              },
            ),
            tileColor: isEdited ? Colors.yellowAccent : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveStockOpname(context),
        child: Icon(Icons.save),
      ),
    );
  }

  Future<void> _saveStockOpname(BuildContext context) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menyimpan perubahan stok?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      List<StockOpnameData> stockOpnameDataList = [];

      for (var item in items) {
        if (item.isEditing) {
          stockOpnameDataList.add(
            StockOpnameData(
              itemName: item.name,
              oldQuantity: item.quantity,
              newQuantity: item.newQuantity,
            ),
          );
          item.isEditing = false;
        } else {
          // Item is not edited, show error and prevent saving
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please edit all items before saving.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      await _saveStockOpnameToFirestore(stockOpnameDataList);

      bool? viewResult = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Konfirmasi'),
            content: Text('Apakah Anda ingin melihat data stock opname?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Tidak'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Ya'),
              ),
            ],
          );
        },
      );

      if (viewResult != null && viewResult) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StockOpnameResultPage()),
        );
      }
    }
  }

  Future<void> _saveStockOpnameToFirestore(List<StockOpnameData> stockOpnameDataList) async {
    try {
      final DateTime currentDate = DateTime.now();
      final CollectionReference stockOpnameRef = FirebaseFirestore.instance.collection('stock_opname');

      await stockOpnameRef.add({
        'date': currentDate,
        'data': stockOpnameDataList.map((data) => data.toMap()).toList(),
      });

      // Update the ingredient collection with new quantities
      final CollectionReference ingredientRef = FirebaseFirestore.instance.collection('ingredient');
      for (var stockOpnameData in stockOpnameDataList) {
        final QuerySnapshot snapshot = await ingredientRef.where('name', isEqualTo: stockOpnameData.itemName).limit(1).get();
        final List<QueryDocumentSnapshot> documents = snapshot.docs;

        if (documents.isNotEmpty) {
          final DocumentSnapshot document = documents.first;
          await ingredientRef.doc(document.id).update({'quantity': stockOpnameData.newQuantity});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock opname saved successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save stock opname. Please try again.'),
        ),
      );
    }
  }
}

class Item {
  final String id;
  final String name;
  int quantity;
  int newQuantity;
  bool isEditing;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
  })   : newQuantity = quantity,
        isEditing = false;
}

class StockOpnameData {
  final String itemName;
  final int oldQuantity;
  final int newQuantity;

  StockOpnameData({
    required this.itemName,
    required this.oldQuantity,
    required this.newQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'oldQuantity': oldQuantity,
      'newQuantity': newQuantity,
    };
  }
}

void main() {
  runApp(MaterialApp(
    home: StockOpnamePage(),
  ));
}
