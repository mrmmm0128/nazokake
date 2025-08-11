import 'package:flutter/material.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/pages/TimelineScreen.dart';
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
  bool _isBlocked = false; // ← 追加
  @override
  Widget build(BuildContext context) {
    final deviceId = getDeviceUUID();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // ← デフォルトの戻るを消す
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // ① 既存のTimelineScreenに戻るだけで良いなら:
            // Navigator.pop(context, /* 例えば true などの結果 */);

            // ② 常にTimelineScreenへ遷移したい＆スタックを増やしたくないなら（おすすめ）:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TimelineScreen()),
            );

            // ③ 完全にトップへ戻して初期化したいなら:
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(builder: (_) => const TimelineScreen()),
            //   (route) => false,
            // );
          },
        ),
        title: const Text(
          "このユーザーのタイムライン",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

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
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ユーザーをブロック'),
                      content: const Text(
                        'このユーザーをブロックしますか？\n'
                        'ブロックすると、このユーザーの投稿が表示されなくなります。\n'
                        'この操作は取り消せません。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            'キャンセル',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
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
                  // ① まずこの画面を空表示に（即時反映）
                  if (mounted) setState(() => _isBlocked = true);

                  try {
                    final me =
                        await getDeviceUUID(); // あなたの実装に合わせて String/Future<String> を使用
                    await FirestoreService().blockUser(me, widget.postDeviceId);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ユーザーをブロックしました。')),
                    );
                    // ② ここでは pop しない（ユーザーがスワイプ/戻るで離れる想定）
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _isBlocked = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ブロックに失敗しました')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          // ブロックしていたら true、していなければ null を親へ返す
          Navigator.of(context).pop(_isBlocked ? true : null);
          return false; // ここで自前で pop 済みなのでデフォルトの戻るはキャンセル
        },
        child: _isBlocked
            ? const Center(
                child: Text(
                  'このユーザーはブロックされました。',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : StreamBuilder<List<Riddle>>(
                stream: FirestoreService().getRiddlesByUser(
                  widget.postDeviceId,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final riddles = snapshot.data!;
                  if (riddles.isEmpty) {
                    return const Center(
                      child: Text(
                        'この投稿者のなぞかけはまだありません。',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      itemCount: riddles.length,
                      itemBuilder: (context, index) =>
                          RiddleCard(riddle: riddles[index]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
