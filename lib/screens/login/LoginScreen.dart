import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  final String apiUrl =
      'http://192.168.1.7:8080/TalkTally-HablarCuenta-1.0/UserServicesRest/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // EMAIL FIELD
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
              onSaved: (value) => _email = value!,
            ),

            SizedBox(height: 20),

            // PASSWORD FIELD
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onSaved: (value) => _password = value!,
            ),

            SizedBox(height: 20),

            // LOGIN BUTTON
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (await login(_email, _password)) {
                    Navigator.pushNamed(context, '/homeScreen');
                  }
                }
              },
              child: Text('Login'),
            ),

            // SIGN UP BUTTON
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
                // Implement your signup navigation logic here
                // You can navigate to the signup screen using Navigator.push().
              },
              child: Text('Sign Up'),
            ),

            // FORGOT PASSWORD BUTTON
            TextButton(
              onPressed: () {
                // Implement your forget password navigation logic here
                // You can navigate to the forget password screen using Navigator.push().
              },
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    ));
  }

  Future<bool> login(String mail, String password) async {
    bool success = false;
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'mail': mail, 'password': password});

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successful signup
        final responseBody = jsonDecode(response.body);

        // Assuming the response contains a 'success' field indicating login success
        if (responseBody['"error" -> true'] == true) {
          // Login was not successful according to the response
          success = false;
          print('Login successful');
        } else {
          success = true;
        }
        print(response.body);
      } else {
        // Signup failed
        print('Login failed with status code: ${response.statusCode}');
        print(response.body);
        success = false;
      }
    } catch (error) {
      print('Error during signup: $error');
    }

    return success;
  }
}
