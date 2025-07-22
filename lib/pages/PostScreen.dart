import 'package:flutter/material.dart';
import 'package:nazokake/util/FirebaseService.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _firstTopicController = TextEditingController();
  final _secondTopicController = TextEditingController();
  final _answerController = TextEditingController();

  void _postRiddle() async {
    final first = _firstTopicController.text.trim();
    final second = _secondTopicController.text.trim();
    final answer = _answerController.text.trim();

    if (first.isEmpty || second.isEmpty || answer.isEmpty) return;

    final question = "$firstとかけまして$secondとかけます。その心は";
    final fullAnswer = "$answerでしょう。";

    await FirestoreService().addRiddle(question, fullAnswer);

    _firstTopicController.clear();
    _secondTopicController.clear();
    _answerController.clear();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("なぞかけ投稿")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("〇〇とかけまして〇〇とかけます。その心は〇〇でしょう。"),
            const SizedBox(height: 16),
            TextField(
              controller: _firstTopicController,
              decoration: const InputDecoration(labelText: '前半のお題（例：すし）'),
            ),
            TextField(
              controller: _secondTopicController,
              decoration: const InputDecoration(labelText: '後半のお題（例：ITエンジニア）'),
            ),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: '答え（例：ネタが重要）'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _postRiddle, child: const Text('投稿')),
          ],
        ),
      ),
    );
  }
}
