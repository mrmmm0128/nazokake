import 'package:flutter/material.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/util/FirebaseService.dart';
import 'package:nazokake/util/GetDeviceId.dart';
import 'package:nazokake/widgets/RiddleCard.dart';

class TimelineForUser extends StatefulWidget {
  final String postDeviceId; // 表示する投稿者のデバイスID
  const TimelineForUser({super.key, required this.postDeviceId});

  @override
  State<TimelineForUser> createState() => _TimelineForUserState();
}

class _TimelineForUserState extends State<TimelineForUser> {
  @override
  Widget build(BuildContext context) {
    final deviceId = getDeviceUUID();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text(
          "このユーザーのタイムライン",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'block',
                  child: const Text('このユーザーをブロックする'),
                ),
              ];
            },
            onSelected: (String value) async {
              if (value == 'block') {
                // ブロック機能の実装
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ユーザーをブロック'),
                      content: const Text(
                        'このユーザーをブロックしますか？\nブロックすると、このユーザーの投稿が表示されなくなります。\nこの操作は取り消せません。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // ダイアログを閉じる
                          },
                          child: const Text(
                            'キャンセル',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(true); // ダイアログを閉じる
                          },
                          child: const Text(
                            'ブロック',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  // ブロック処理を実行
                  await FirestoreService().blockUser(
                    await deviceId,
                    widget.postDeviceId,
                  );

                  // SnackBar を表示
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ユーザーをブロックしました。')),
                  );

                  // 元の画面に戻る
                  Navigator.pop(context, true); // true を返して元の画面で再取得をトリガー
                  setState(() {});
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Riddle>>(
        stream: FirestoreService().getRiddlesByUser(widget.postDeviceId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final riddles = snapshot.data!;

          if (riddles.isEmpty) {
            return const Center(
              child: Text(
                "この投稿者のなぞかけはまだありません。",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // データを再取得
            },
            child: ListView.builder(
              itemCount: riddles.length,
              itemBuilder: (context, index) {
                return RiddleCard(riddle: riddles[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
