import 'package:flutter/material.dart';
import 'package:nazokake/util/FirebaseService.dart';
import 'package:nazokake/util/GetDeviceId.dart';
import 'dart:math';
import 'package:nazokake/model/kansu.dart';

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

  void _setRandomTopic(TextEditingController controller) {
    final _nouns = nounsNN;
    final random = Random();
    // リストの中からランダムに1つの単語を選ぶ
    final randomTopic = _nouns[random.nextInt(_nouns.length)];

    // TextFieldのテキストをランダムに選んだ単語に設定する
    setState(() {
      controller.text = randomTopic;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      backgroundColor: secondaryColor, // 背景色を白に設定
      appBar: AppBar(
        title: const Text("なぞかけ投稿"),
        backgroundColor: primaryColor,
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
              const Text("お題はランダムで決めることもできます！"),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstTopicController,
                              decoration: InputDecoration(
                                fillColor: secondaryColor,
                                filled: true,
                                labelText: '例：牛丼',
                                labelStyle: TextStyle(fontSize: 16),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.shuffle, color: primaryColor),
                            onPressed: () =>
                                _setRandomTopic(_firstTopicController),
                            tooltip: 'ランダムなお題を設定',
                          ),
                        ],
                      ),
                      Text('とかけまして'),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _secondTopicController,
                              decoration: InputDecoration(
                                fillColor: secondaryColor,
                                filled: true,
                                labelText: '例：海',
                                labelStyle: TextStyle(fontSize: 16),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.shuffle, color: primaryColor),
                            onPressed: () =>
                                _setRandomTopic(_secondTopicController),
                            tooltip: 'ランダムなお題を設定',
                          ),
                        ],
                      ),
                      Text('とときます。そのこころは、どちらも'),
                      SizedBox(height: 12),
                      TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          labelText: '例：なみ（並・波）があるでしょう',
                          labelStyle: TextStyle(fontSize: 16),
                          fillColor: secondaryColor,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
