import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sample_chatapp/widget/imagepick.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var enteredemail = '';
  var enteredpassword = '';
  var enterusername = '';
  File? selectedImage;
  var _isAuthenticating = false;

  final formkey = GlobalKey<FormState>();
  void _sumit() async {
    final isvalid = formkey.currentState!.validate();
    if (!isvalid || !_login && selectedImage == null) {
      return;
    }
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_login) {
        final usercrediential = await _firebase.signInWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);
      } else {
        final usercrediential = await _firebase.createUserWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${usercrediential.user!.uid}.jpg');

        await storageRef.putFile(selectedImage!);
        final ImageUrl = await storageRef.getDownloadURL();
        print(ImageUrl);

        FirebaseFirestore.instance
            .collection('users')
            .doc(usercrediential.user!.uid)
            .set({
          'username': enterusername,
          'email': enteredemail,
          'image_url': ImageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}

      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')));
      setState(() {
        _isAuthenticating = false;
      });
    }

    formkey.currentState!.save();
    print(enteredemail);
    print(enteredpassword);
  }

  var _login = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_login)
                            UserImagePicker(
                              onPickedImage: (pickedimage) {
                                selectedImage = pickedimage;
                              },
                            ),
                          if (!_login)
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text('Username')),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'enter valid userid';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                enterusername = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'please enter valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              enteredemail = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.length < 6) {
                                return 'enter valid password';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              enteredpassword = newValue!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                                onPressed: _sumit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_login ? "login" : 'signup')),
                          if (!_isAuthenticating)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _login = !_login;
                                  });
                                },
                                child: Text(_login
                                    ? 'Create an account'
                                    : 'I already have account'))
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}