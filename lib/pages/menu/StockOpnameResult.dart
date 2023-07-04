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
        final stockOpnameData =
        snapshot.docs.first.data() as Map<String, dynamic>;
        final List<dynamic>? data = stockOpnameData['data'];

        if (data != null) {
          setState(() {
            stockOpnameDataList = data.map((item) {
              return StockOpnameData(
                itemId: item?['itemName'] ?? '',
                oldQuantity: item?['oldQuantity'] ?? 0,
                newQuantity: item?['newQuantity'] ?? 0,
                hasDifference: item?['hasDifference'] ?? false,
                description: item?['description'] ?? '',
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
            );
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
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: stockOpnameDataList.length,
              itemBuilder: (context, index) {
                final stockOpnameData = stockOpnameDataList[index];

                return ListTile(
                  title: Text(
                    'Item ID: ${stockOpnameData.itemId}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Old Quantity: ${stockOpnameData.oldQuantity}',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'New Quantity: ${stockOpnameData.newQuantity}',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      if (stockOpnameData.hasDifference)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Description: ${stockOpnameData.description}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 8),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        child: Icon(
          Icons.home,
          color: Colors.white,
        ),
        backgroundColor: Colors.brown,
      ),
    );
  }
}

class StockOpnameData {
  final String itemId;
  final int oldQuantity;
  final int newQuantity;
  final bool hasDifference;
  final String description;

  StockOpnameData({
    required this.itemId,
    required this.oldQuantity,
    required this.newQuantity,
    this.hasDifference = false,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'oldQuantity': oldQuantity,
      'newQuantity': newQuantity,
      'hasDifference': hasDifference,
      'description': description,
    };
  }
}
