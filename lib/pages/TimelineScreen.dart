import 'package:flutter/material.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/pages/PostScreen.dart';
import 'package:nazokake/util/FirebaseService.dart';
import 'package:nazokake/widgets/RiddleCard.dart';

enum SortOption { newest, mostLiked }

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  SortOption _sort = SortOption.newest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("なぞかけタイムライン"),
        actions: [
          PopupMenuButton<SortOption>(
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: SortOption.newest, child: Text("最新順")),
              const PopupMenuItem(
                value: SortOption.mostLiked,
                child: Text("いいね順"),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Riddle>>(
        stream: FirestoreService().getRiddlesSorted(_sort),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final riddles = snapshot.data!;
          return ListView.builder(
            itemCount: riddles.length,
            itemBuilder: (context, index) {
              return RiddleCard(riddle: riddles[index]);
            },
          );
        },
      ),
    );
  }
}
