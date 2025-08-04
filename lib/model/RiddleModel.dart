import 'package:cloud_firestore/cloud_firestore.dart';

class Riddle {
  final String id;
  final String question1;
  final String question2;
  final String answer;
  late final List<String> likes;
  final DateTime timestamp;
  final String postDeviceId;

  Riddle({
    required this.id,
    required this.question1,
    required this.question2,
    required this.answer,
    required this.likes,
    required this.timestamp,
    required this.postDeviceId,
  });

  factory Riddle.fromMap(String id, Map<String, dynamic> data) {
    return Riddle(
      id: id, // デバイスIDを投稿者IDとして使用
      question1: data['question1'],
      question2: data['question2'],
      answer: data['answer'],
      likes: List<String>.from(data['likes'] ?? []),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      postDeviceId: data['post_deviceId'] ?? '',
    );
  }
}
