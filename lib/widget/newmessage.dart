import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessafe extends StatefulWidget {
  const NewMessafe({super.key});

  @override
  State<NewMessafe> createState() => _NewMessafeState();
}

class _NewMessafeState extends State<NewMessafe> {
  var messagecontroller = TextEditingController();
  @override
  void dispose() {
    messagecontroller.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    FocusScope.of(context).unfocus();
    final enteredMessage = messagecontroller.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    messagecontroller.clear();

    
    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userimage': userData.data()!['image_url'],
    });

    
    
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 1,
          bottom: 15,
        ),
        child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: messagecontroller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'send message.....'),
            )),
            IconButton(
              onPressed: _submitMessage,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}
