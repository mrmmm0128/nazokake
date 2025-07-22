import 'package:cloud_firestore/cloud_firestore.dart';

class Riddle {
  final String id;
  final String question;
  final String answer;
  final List<String> likes;
  final DateTime timestamp;

  Riddle({
    required this.id,
    required this.question,
    required this.answer,
    required this.likes,
    required this.timestamp,
  });

  factory Riddle.fromMap(String id, Map<String, dynamic> data) {
    return Riddle(
      id: id,
      question: data['question'],
      answer: data['answer'],
      likes: List<String>.from(data['likes'] ?? []),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
