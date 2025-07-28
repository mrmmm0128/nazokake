import 'package:flutter/material.dart';
import 'package:nazokake/util/FirebaseService.dart';
import 'package:nazokake/util/GetDeviceId.dart';

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

    final question1 = first;
    final question2 = second;
    final fullAnswer = answer;
    final deviceId = await getDeviceUUID(); // デバイスIDを取得

    await FirestoreService().addRiddle(
      question1,
      question2,
      fullAnswer,
      deviceId,
    );

    _firstTopicController.clear();
    _secondTopicController.clear();
    _answerController.clear();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: const Text("なぞかけ投稿"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "なぞかけを投稿しましょう！",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("例：\n牛丼とかけまして海とときます。\nそのこころは どちらもなみ（並・波）があるでしょう。"),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _firstTopicController,
                        decoration: const InputDecoration(
                          labelText: '前半のお題',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                      Text('とかけまして'),
                      TextField(
                        controller: _secondTopicController,
                        decoration: const InputDecoration(
                          labelText: '後半のお題',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                      Text('とときます。そのこころは、どちらも'),
                      TextField(
                        controller: _answerController,
                        decoration: const InputDecoration(labelText: '答え'),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _postRiddle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('投稿'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
