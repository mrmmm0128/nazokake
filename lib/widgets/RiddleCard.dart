import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/model/kansu.dart';
import 'package:nazokake/pages/EditRiddle.dart';
import 'package:nazokake/pages/TimelineScreen.dart';
import 'package:nazokake/pages/TimelineForUser.dart';
import 'package:nazokake/util/FirebaseService.dart';
import 'package:nazokake/util/GetDeviceId.dart';

class RiddleCard extends StatefulWidget {
  final Riddle riddle;
  final ValueChanged<String>? onHide; // ★ 追加

  const RiddleCard({
    super.key,
    required this.riddle,
    this.onHide, // ★ 追加
  });

  @override
  State<RiddleCard> createState() => _RiddleCardState();
}

class _RiddleCardState extends State<RiddleCard> {
  bool _showAnswer = false;
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    _deviceId = await getDeviceUUID();
    setState(() {}); // デバイスIDを取得したら再描画
  }

  void _toggleLike() async {
    // Firestore のデータを更新
    await FirestoreService().toggleLike(widget.riddle.id, widget.riddle.likes);

    // Firestore から最新のデータを取得して同期
    final updatedRiddle = await FirestoreService().getRiddleById(
      widget.riddle.id,
    );

    // UI を更新
    setState(() {
      widget.riddle.likes = updatedRiddle.likes;
    });
  }

  Future<void> saveRiddle() async {
    await FirestoreService().saveRiddle(widget.riddle.id, _deviceId);
    setState(() {}); // 保存後に再描画
  }

  void _navigateToUserRiddles(String postDeviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimelineForUser(postDeviceId: postDeviceId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isLiked = widget.riddle.likes.contains(_deviceId);
    // 投稿者が自分ならColorを変更
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return InkWell(
      onTap: () => setState(() => _showAnswer = !_showAnswer),
      child: Card(
        color: widget.riddle.postDeviceId == _deviceId
            ? secondaryColor // 投稿者のカードは薄い色
            : Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.riddle.question1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: " とかけまして\n",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          TextSpan(
                            text: widget.riddle.question2,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: " とときます。",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // メニューバー
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onSelected: (value) async {
                      if (value == '削除') {
                        // 確認ダイアログを表示
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('投稿を削除しますか？'),
                              content: const Text('この操作は元に戻せません。'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // ダイアログを閉じる
                                  },
                                  child: const Text('キャンセル'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // ダイアログを閉じる
                                    await FirestoreService().deleteRiddle(
                                      widget.riddle.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('投稿を削除しました'),
                                      ),
                                    );
                                  },
                                  child: const Text('削除'),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (value == '編集') {
                        // 編集画面に遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditScreen(
                              editRiddlesId: widget.riddle.id,
                              firstTopic: widget.riddle.question1,
                              secondTopic: widget.riddle.question2,
                              answer: widget.riddle.answer,
                            ),
                          ),
                        );
                      } else if (value == '通報') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('投稿を通報しますか？'),
                              content: const Text('不適切な内容が含まれている場合は通報してください。'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // ダイアログを閉じる
                                  },
                                  child: const Text(
                                    'キャンセル',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // ダイアログを閉じる
                                    // 通報処理
                                    await FirestoreService().reportRiddle(
                                      widget.riddle.id,
                                      _deviceId,
                                      '不適切な内容', // Add the missing positional argument
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('投稿を通報しました'),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    '通報',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (value == '非表示') {
                        // ① 先にUIから消す（親に通知）
                        widget.onHide?.call(widget.riddle.id);

                        // ❌ 下の行は意味がないので削除（画面遷移していない）
                        // MaterialPageRoute(builder: (context) => TimelineScreen());
                      } else if (value == '他の投稿') {
                        // このユーザーの他の投稿を表示
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimelineForUser(
                              postDeviceId: widget.riddle.postDeviceId,
                            ),
                          ),
                        );

                        if (result == true) {
                          // データを再取得
                          setState(() {});
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      if (widget.riddle.postDeviceId == _deviceId)
                        const PopupMenuItem(value: '削除', child: Text('削除')),
                      if (widget.riddle.postDeviceId == _deviceId)
                        const PopupMenuItem(value: '編集', child: Text('編集')),
                      if (widget.riddle.postDeviceId != _deviceId)
                        const PopupMenuItem(value: '通報', child: Text('通報')),
                      if (widget.riddle.postDeviceId != _deviceId)
                        const PopupMenuItem(value: '非表示', child: Text('非表示')),
                      if (widget.riddle.postDeviceId != _deviceId)
                        const PopupMenuItem(value: '他の投稿', child: Text('他の投稿')),
                    ],
                  ),
                ],
              ),
              if (_showAnswer)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'そのこころは、どちらも\n',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        TextSpan(
                          text: widget.riddle.answer,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  // タイムスタンプを左側に配置
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      Text(
                        ' ${formatTimeAgo(widget.riddle.timestamp)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Spacer(), // 左右の間にスペースを挿入
                  // 通報ボタンといいねボタンを右寄せに配置
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 引用
                      //IconButton(
                      //  onPressed: () {
                      //    // 保存機能の実装
                      //    ScaffoldMessenger.of(context).showSnackBar(
                      //      const SnackBar(content: Text('引用ボタン（未実装）')),
                      //    );
                      //  },
                      //  icon: const Icon(
                      //    Icons.format_quote,
                      //    size: 16,
                      //    color: Colors.grey,
                      //  ),
                      //),
                      //　保存
                      FutureBuilder<bool>(
                        future: FirestoreService().isRiddleSaved(
                          widget.riddle.id,
                          _deviceId,
                        ),
                        builder: (context, snapshot) {
                          var isSaved = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              Icons.save,
                              size: 16,
                              color: isSaved ? primaryColor : Colors.grey,
                            ),
                            onPressed: () {
                              saveRiddle();
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text(
                        '${widget.riddle.likes.length}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
