import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = '';

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      String newPassword = _newPasswordController.text.trim();

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(newPassword);
          print('Password berhasil diubah.');
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = 'User tidak ditemukan.';
          });
        }
      } catch (error) {
        print('Gagal mengubah password: $error');
        setState(() {
          _errorMessage = 'Gagal mengubah password.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Password'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                obscureText: true,
                controller: _newPasswordController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter new password.';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                ),
                obscureText: true,
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm new password.';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Password does not match.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Change Password'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
