import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  Map<String, dynamic> payload = {};
  String? title;
  String? body;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = ModalRoute.of(context)!.settings.arguments;

    try {
      if (data is RemoteMessage) {
        setState(() {
          payload = data.data;
          title = data.notification?.title;
          body = data.notification?.body;
        });
      } else if (data is NotificationResponse) {
        setState(() {
          // Safely decode JSON payload
          try {
            if (data.payload != null && data.payload!.isNotEmpty) {
              payload = jsonDecode(data.payload!) as Map<String, dynamic>;
            }
          } catch (e) {
            print('Error decoding payload: $e');
          }
        });
      }
    } catch (e) {
      print('Error processing notification data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              const Text(
                'Title:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(title!),
              const SizedBox(height: 16),
            ],
            if (body != null) ...[
              const Text(
                'Message:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(body!),
              const SizedBox(height: 16),
            ],
            if (payload.isNotEmpty) ...[
              const Text(
                'Additional Data:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: payload.length,
                  itemBuilder: (context, index) {
                    String key = payload.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(payload[key].toString()),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (title == null && body == null && payload.isEmpty)
              const Center(
                child: Text(
                  'No notification data available',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
