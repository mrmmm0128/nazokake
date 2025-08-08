String formatTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}分前';
  } else if (diff.inHours < 3) {
    return '${diff.inHours}時間前';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}時間前';
  } else if (diff.inHours < 48) {
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

final List<String> nounsNN = [
  'スマートフォン',
  'パソコン',
  '冷蔵庫',
  '洗濯機',
  'テレビ',
  'エアコン',
  '扇風機',
  '猫',
  '犬',
  'うさぎ',
  'ライオン',
  'キリン',
  'ぞう',
  'パンダ',
  'お寿司',
  'ラーメン',
  'カレーライス',
  '焼肉',
  'ピザ',
  'ハンバーガー',
  'サッカー',
  '野球',
  'バスケットボール',
  'テニス',
  '水泳',
  '学校',
  '会社',
  '病院',
  '駅',
  '公園',
  'コンビニ',
  '春',
  '夏',
  '秋',
  '冬',
  '空',
  '海',
  '山',
  '川',
  '音楽',
  '映画',
  '読書',
  '旅行',
  'ゲーム',
  'アイドル',
  'YouTube',
  '愛',
  '夢',
  '希望',
  '友情',
  '時間',
  'お金',
  '健康',
];

// 禁止ワードリスト（必要に応じて拡張可）
final List<String> prohibitedWords = [
  'ちんこ',
  'まんこ',
  'うんこ',
  'しね',
  'fuck',
  '死ね',
  'sex',
  'セックス',
  'ち○こ', // 回避的表記対策も追加可能
];
