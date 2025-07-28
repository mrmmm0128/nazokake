String formatTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}分前';
  } else if (diff.inHours < 3) {
    return '${diff.inHours}時間前';
  } else if (diff.inHours < 12) {
    return '${diff.inHours}時間前';
  } else if (diff.inHours < 24) {
    return '1日';
  } else if (diff.inDays < 7) {
    return '${diff.inDays}日前';
  } else if (diff.inDays < 30) {
    return '${(diff.inDays / 7).floor()}週間前';
  } else if (diff.inDays < 90) {
    return '${(diff.inDays / 30).floor()}ヶ月前';
  } else {
    return '${timestamp.year}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}';
  }
}
