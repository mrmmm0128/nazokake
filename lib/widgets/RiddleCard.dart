import 'package:flutter/material.dart';
import 'package:nazokake/model/RiddleModel.dart';
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
    _deviceId = getDeviceIDweb();
  }

  void _toggleLike() {
    FirestoreService().toggleLike(widget.riddle.id, widget.riddle.likes);
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.riddle.likes.contains(_deviceId);

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(widget.riddle.question),
        subtitle: _showAnswer ? Text("答え：${widget.riddle.answer}") : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.riddle.likes.length}'),
            IconButton(
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
              onPressed: () => _toggleLike(),
            ),
          ],
        ),
        onTap: () => setState(() => _showAnswer = !_showAnswer),
      ),
    );
  }
}
