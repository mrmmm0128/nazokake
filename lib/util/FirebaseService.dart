import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/pages/TimelineScreen.dart';
import 'package:nazokake/util/GetDeviceId.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final deviceId = getDeviceUUID();

  Future<void> addRiddle(
    String question1,
    String question2,
    String answer,
    String deviceId,
  ) async {
    await _db.collection('riddles').add({
      'post_deviceId': deviceId,
      'question1': question1,
      'question2': question2,
      'answer': answer,
      'likes': [],
      'timestamp': Timestamp.now(),
    });
  }

  Stream<List<Riddle>> getMyRiddles(String deviceId) {
    return _db
        .collection('riddles')
        .where('post_deviceId', isEqualTo: deviceId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Riddle.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // 謎かけを保存
  // deviceId: 保存するデバイスのID
  // riddleId: 保存する謎かけのID
  // riddle_deviceコレクション内にdeviceIDがない場合、作成してからriddleIdを追加
  // 謎かけがすでに保存されている場合は、riddleIdを追加する
  // riddleIdがすでに存在する場合は、削除する
  Future<void> saveRiddle(String riddleId, String deviceId) async {
    final docRef = _db.collection('riddle_device').doc(deviceId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['riddles'] != null) {
        final riddles = List<String>.from(data['riddles']);
        if (riddles.contains(riddleId)) {
          // すでに保存されている場合は削除
          await docRef.update({
            'riddles': FieldValue.arrayRemove([riddleId]),
          });
          return;
        }
      }
    }

    // 保存されていない場合は追加
    await docRef.set({
      'deviceId': deviceId,
      'riddles': FieldValue.arrayUnion([riddleId]),
    }, SetOptions(merge: true));
  }

  // 他の人のなぞかけを非表示にする
  Future<void> hideRiddle(String riddleId, String deviceId) async {
    final docRef = _db.collection('hidden_riddles').doc(deviceId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // すでにある場合は arrayUnion だけでOK（重複チェック不要）
      await docRef.update({
        'riddles': FieldValue.arrayUnion([riddleId]),
      });
    } else {
      // なければ新規作成
      await docRef.set({
        'deviceId': deviceId,
        'riddles': [riddleId],
      });
    }
  }

  // ユーザーをブロックする
  Future<void> blockUser(String deviceId, String targetDeviceId) async {
    final docRef = _db.collection('blockcollection').doc(deviceId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // すでにある場合は arrayUnion だけでOK（重複チェック不要）
      await docRef.update({
        'blockedUsers': FieldValue.arrayUnion([targetDeviceId]),
      });
    } else {
      // なければ新規作成
      await docRef.set({
        'deviceId': deviceId,
        'blockedUsers': [targetDeviceId],
      });
    }
  }

  // 謎かけが保存されているか確認
  Future<bool> isRiddleSaved(String riddleId, String deviceId) async {
    final docRef = _db.collection('riddle_device').doc(deviceId);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['riddles'] != null) {
        final riddles = List<String>.from(data['riddles']);
        return riddles.contains(riddleId);
      }
    }
    return false;
  }

  // 保存された謎かけを取得
  Stream<List<Riddle>> getSavedRiddles(String deviceId) {
    return _db
        .collection('riddle_device')
        .doc(deviceId)
        .snapshots()
        .asyncExpand((snapshot) async* {
          if (!snapshot.exists) yield [];
          final data = snapshot.data();
          if (data == null || data['riddles'] == null) yield [];
          final riddles = List<String>.from(data!['riddles']);
          yield* _db
              .collection('riddles')
              .where(FieldPath.documentId, whereIn: riddles)
              .snapshots()
              .map(
                (snapshot) => snapshot.docs
                    .map((doc) => Riddle.fromMap(doc.id, doc.data()))
                    .toList(),
              );
        });
  }

  Stream<List<Riddle>> getRiddlesSorted(SortOption sort) {
    Query query = _db.collection('riddles');
    if (sort == SortOption.newest) {
      query = query.orderBy('timestamp', descending: true);
    } else {
      query = query.orderBy('likes', descending: true);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => Riddle.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  // 特定のユーザーのナゾカケを取得
  Stream<List<Riddle>> getRiddlesByUser(String deviceId) {
    return _db
        .collection('riddles')
        .where('post_deviceId', isEqualTo: deviceId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Riddle.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> deleteRiddle(String riddleId) async {
    await _db.collection('riddles').doc(riddleId).delete();
  }

  Future<void> toggleLike(String riddleId, List<String> currentLikes) async {
    final id = await getDeviceUUID();
    final docRef = _db.collection('riddles').doc(riddleId);

    if (currentLikes.contains(id)) {
      await docRef.update({
        'likes': FieldValue.arrayRemove([id]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayUnion([id]),
      });
    }
  }

  Future<Riddle> getRiddleById(String riddleId) async {
    final docSnapshot = await _db.collection('riddles').doc(riddleId).get();
    if (docSnapshot.exists) {
      return Riddle.fromMap(
        docSnapshot.id,
        docSnapshot.data() as Map<String, dynamic>,
      );
    } else {
      throw Exception('Riddle not found');
    }
  }

  Future<List<String>> getHiddenRiddleIds(String deviceId) async {
    final docSnapshot = await _db
        .collection('hidecollection')
        .doc(deviceId)
        .get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['riddles'] != null) {
        return List<String>.from(data['riddles']);
      }
    }
    return [];
  }

  // ブロックしたユーザーのナゾカケを取得
  Future<List<String>> getBlockedUserIds(String deviceId) async {
    final docSnapshot = await _db
        .collection('blockcollection')
        .doc(deviceId)
        .get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['blockedUsers'] != null) {
        return List<String>.from(data['blockedUsers']);
      }
    }
    return [];
  }

  // 通報内容を報告
  Future<void> reportRiddle(
    String riddleId,
    String reporterDeviceID,
    String reason,
  ) async {
    // reportsコレクションに報告内容を追加
    await _db.collection('reports').add({
      'riddleId': riddleId,
      'reason': reason,
      'reporterDeviceId': reporterDeviceID,
      'timestamp': Timestamp.now(),
    });
  }
}
