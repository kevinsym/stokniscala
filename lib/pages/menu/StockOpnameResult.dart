import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockniscala/pages/HomeScreen.dart';

class StockOpnameResultPage extends StatefulWidget {
  @override
  _StockOpnameResultPageState createState() => _StockOpnameResultPageState();
}

class _StockOpnameResultPageState extends State<StockOpnameResultPage> {
  List<StockOpnameData> stockOpnameDataList = [];
  DateTime stockOpnameDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchStockOpnameData();
  }

  Future<void> fetchStockOpnameData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stock_opname')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final stockOpnameData = snapshot.docs.first.data() as Map<String, dynamic>;
        final List<dynamic>? data = stockOpnameData?['data'];

        if (data != null) {
          setState(() {
            stockOpnameDataList = data.map((item) {
              return StockOpnameData(
                itemId: item?['itemName'] ?? '',
                oldQuantity: item?['oldQuantity'] ?? 0,
                newQuantity: item?['newQuantity'] ?? 0,
              );
            }).toList();

            stockOpnameDate = stockOpnameData['date'].toDate();
          });
        }
      }
    } catch (error) {
      print('Failed to fetch stock opname data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Opname Result'),
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            ); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Stock Opname Date: ${stockOpnameDate.day}-${stockOpnameDate.month}-${stockOpnameDate.year}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: stockOpnameDataList.length,
              itemBuilder: (context, index) {
                final stockOpnameData = stockOpnameDataList[index];

                return ListTile(
                  title: Text('Item ID: ${stockOpnameData.itemId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Old Quantity: ${stockOpnameData.oldQuantity}'),
                      Text('New Quantity: ${stockOpnameData.newQuantity}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StockOpnameData {
  final String itemId;
  final int oldQuantity;
  final int newQuantity;

  StockOpnameData({
    required this.itemId,
    required this.oldQuantity,
    required this.newQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'oldQuantity': oldQuantity,
      'newQuantity': newQuantity,
    };
  }
}

void main() {
  runApp(MaterialApp(
    home: StockOpnameResultPage(),
  ));
}
