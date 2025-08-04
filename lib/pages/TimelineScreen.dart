import 'package:flutter/material.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/pages/PostScreen.dart';
import 'package:nazokake/pages/TermsAgreement.dart';
import 'package:nazokake/util/FirebaseService.dart';
import 'package:nazokake/util/GetDeviceId.dart';
import 'package:nazokake/widgets/RiddleCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortOption { newest, mostLiked, onlyMine, saved }

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  SortOption _sort = SortOption.newest;
  bool _isAgreementChecked = false;

  @override
  void initState() {
    super.initState();
    _checkAgreement();
  }

  Future<void> _checkAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAgreed = prefs.getBool('agreed_to_terms') ?? false;

    if (!hasAgreed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => TermsAgreementDialog(
            onAgreed: () async {
              await prefs.setBool('agreed_to_terms', true);
              Navigator.of(context).pop(); // ダイアログを閉じる
              setState(() {
                _isAgreementChecked = true;
              });
            },
          ),
        );
      });
    } else {
      setState(() {
        _isAgreementChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(
      context,
    ).colorScheme.primary; // primaryColor を取得
    final secondaryColor = Theme.of(
      context,
    ).colorScheme.secondary; // secondaryColor を取得
    return Scaffold(
      backgroundColor: secondaryColor, // 背景色を白に設定
      appBar: AppBar(
        title: const Text("なぞかけタイムライン"),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<SortOption>(
            onSelected: (value) => setState(() => _sort = value),
            initialValue: _sort,
            icon: const Icon(Icons.sort),
            itemBuilder: (context) => [
              const PopupMenuItem(value: SortOption.newest, child: Text("最新順")),
              const PopupMenuItem(
                value: SortOption.mostLiked,
                child: Text("いいね順"),
              ),
              const PopupMenuItem(
                value: SortOption.onlyMine,
                child: Text("あなたの投稿"),
              ),
              const PopupMenuItem(
                value: SortOption.saved,
                child: Text("保存した投稿"),
              ),
            ],
          ),
          // 遊び方ボタン
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("遊び方"),
                  content: const Text(
                    "なぞかけを投稿して、みんなと楽しもう！\n\n"
                    "タップで答えを表示\nいいねで応援できます。\n保存すればすぐに見返すことができます\n\n引用機能も実装予定！",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("閉じる"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: getDeviceUUID(),
        builder: (context, deviceUUIDSnapshot) {
          if (!deviceUUIDSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<Riddle>>(
            stream: _sort == SortOption.onlyMine
                ? FirestoreService().getMyRiddles(deviceUUIDSnapshot.data!)
                : _sort == SortOption.saved
                ? FirestoreService().getSavedRiddles(deviceUUIDSnapshot.data!)
                : FirestoreService().getRiddlesSorted(_sort),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final riddles = snapshot.data!;
              return ListView.builder(
                itemCount: riddles.length,
                itemBuilder: (context, index) {
                  return RiddleCard(riddle: riddles[index]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostScreen()),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
