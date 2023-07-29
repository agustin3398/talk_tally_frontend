import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SignUpForm(),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmationCode = '';
  bool _showConfirmationCode = false; // Track whether to show the confirmation code widget

  final String apiUrlSignup =
      'http://192.168.1.7:8080/TalkTally-HablarCuenta-1.0/UserServicesRest/signup';
  final String apiUrlConfirmationCode =
      'http://192.168.1.7:8080/TalkTally-HablarCuenta-1.0/UserServicesRest/send-confirmation-code';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //EMAIL FIELD
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                // Add more email validation checks if required
                return null;
              },
              onSaved: (value) => _email = value!,
            ),

            SizedBox(height: 20),

            //PASSWORD FIELD
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                // TODO Add more password validation checks if required
                return null;
              },
              onSaved: (value) => _password = value!,
            ),

            SizedBox(height: 20),

            // AnimatedOpacity for CONFIRMATION CODE FIELD
            AnimatedOpacity(
              opacity: _showConfirmationCode ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Confirmation Code'),
                validator: (value) {
                  if (value!.isEmpty && _showConfirmationCode) {
                    return 'Please enter the confirmation code';
                  }
                  // Add validation checks for confirmation code if required
                  return null;
                },
                onSaved: (value) => _confirmationCode = value!,
              ),
            ),

            //SIGN UP BUTTON
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (!_showConfirmationCode) {
                    // Show the confirmation code field if not shown
                    setState(() {
                      _showConfirmationCode = true;
                    });

                    if (await requestConfirmationCode(_email, _password)) {

                    }
                  } else {
                    // Process the sign-up with the confirmation code
                    if (await signUp(_email, _password, _confirmationCode)) {
                      Navigator.pushNamed(context, '/login');
                    }
                    // Implement your sign-up logic here
                    // You can save the email, password, and confirmation code to your authentication system/database.
                  }
                }
              },
              child: Text(_showConfirmationCode ? 'Submit' : 'Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> requestConfirmationCode(String mail, String password) async {
    bool success = false;
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'mail': mail,
      'password': password});

    try {
      final response =
      await http.post(Uri.parse(apiUrlConfirmationCode), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successful signup
        print('Signup successful');
        print(response.body);
        success = true;
      } else {
        // Signup failed
        print('Signup failed with status code: ${response.statusCode}');
        print(response.body);
        success = false;
      }
    } catch (error) {
      print('Error during signup: $error');
    }

    return success;
  }
  Future<bool> signUp(String mail, String password, String confirmationCode) async {
    bool success = false;
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'mail': mail,
      'password': password,
      'confirmationCode' : confirmationCode});

    try {
      final response =
      await http.post(Uri.parse(apiUrlSignup), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successful signup
        print('Signup successful');
        print(response.body);
        success = true;
      } else {
        // Signup failed
        print('Signup failed with status code: ${response.statusCode}');
        print(response.body);
        success = false;
      }
    } catch (error) {
      print('Error during signup: $error');
    }

    return success;
  }

}
