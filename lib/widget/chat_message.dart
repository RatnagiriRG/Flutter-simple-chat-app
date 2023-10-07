import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sample_chatapp/widget/message_bubble.dart';


class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  void setupPushnotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
    final token = await fcm.getToken();
    print(token);
  }

  @override
  void initState() {
    super.initState();
    setupPushnotification();
  }

  @override
  Widget build(BuildContext context) {
    final authenticateduser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      // ignore: non_constant_identifier_names
      builder: ((ctx, ChatSnapshots) {
        if (ChatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!ChatSnapshots.hasData || ChatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("no message found"),
          );
        }

        if (ChatSnapshots.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }

        final loadedmessages = ChatSnapshots.data!.docs;

        return Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 40,
                left: 15,
                right: 10,
              ),
              reverse: true,
              itemCount: loadedmessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedmessages[index].data();
                final NextchatMessage = index + 1 < loadedmessages.length
                    ? loadedmessages[index + 1].data()
                    : null;

                final currentMessageuserid = chatMessage['userId'];
                final nextMessageuserid =
                    NextchatMessage != null ? NextchatMessage['userId'] : null;
                final nextUserisSame =
                    nextMessageuserid == currentMessageuserid;

                if (nextUserisSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticateduser.uid == currentMessageuserid);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userimage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticateduser.uid == currentMessageuserid);
                }
              }),
        );
      }),
    );
  }
}
