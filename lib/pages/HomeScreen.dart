import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockniscala/pages/auth/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:stockniscala/pages/changePassword.dart';
import 'package:stockniscala/pages/menu/InputStock.dart';
import 'package:stockniscala/pages/menu/Penjualan.dart';
import 'package:stockniscala/pages/menu/StockOpname.dart';
import 'package:stockniscala/pages/menu/menu.dart';
import 'package:stockniscala/utils/color_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StockNiscala"),
        backgroundColor: Colors.brown,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    hexStringToColor("834200"),
                    hexStringToColor("A4550A"),
                    hexStringToColor("B5651D"),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo_niscala.png',
                    width: 80,
                    height: 80,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Email: " + user.email!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Ubah Password"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            ListTile(
              title: Text("Logout"),
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed Out");
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                });
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: <Widget>[
              buildMenuItem(
                icon: Icons.menu_book_outlined,
                title: "Menu",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Menu()),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.add_business_outlined,
                title: "Penjualan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalesPage()),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.add_chart_outlined,
                title: "Input Stock",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InputStockPage()),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.warehouse,
                title: "Stock Opname",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockOpnamePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.brown,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
