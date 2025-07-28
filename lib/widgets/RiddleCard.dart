import 'package:flutter/material.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/model/kansu.dart';
import 'package:nazokake/util/FirebaseService.dart';
import 'package:nazokake/util/GetDeviceId.dart';

class RiddleCard extends StatefulWidget {
  final Riddle riddle;
  const RiddleCard({super.key, required this.riddle});

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

  void _toggleLike() {
    FirestoreService().toggleLike(widget.riddle.id, widget.riddle.likes);
    setState(() {
      if (widget.riddle.likes.contains(_deviceId)) {
        widget.riddle.likes.remove(_deviceId);
      } else {
        widget.riddle.likes.add(_deviceId);
      }
    });
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
                  Text(
                    "${widget.riddle.question1} とかけまして\n${widget.riddle.question2} とときます。",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                      } else if (value == '通報') {
                        // 通報処理
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('通報機能（未実装）')),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      if (widget.riddle.postDeviceId == _deviceId)
                        const PopupMenuItem(value: '削除', child: Text('削除')),
                      const PopupMenuItem(value: '通報', child: Text('通報')),
                    ],
                  ),
                ],
              ),
              if (_showAnswer)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("そのこころは、どちらも ${widget.riddle.answer}"),
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
                      IconButton(
                        onPressed: () {
                          // 保存機能の実装
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('引用ボタン（未実装）')),
                          );
                        },
                        icon: const Icon(Icons.format_quote, size: 16),
                      ),
                      //　保存
                      IconButton(
                        icon: const Icon(Icons.save_rounded, size: 16),
                        onPressed: () {
                          // 保存機能の実装
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('保存ボタン（未実装）')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : null,
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
