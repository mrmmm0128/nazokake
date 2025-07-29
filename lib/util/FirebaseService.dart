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

  Stream<List<Riddle>> getSavedRiddles(String deviceId) {
    return _db
        .collection('saved_riddles')
        .where('deviceId', isEqualTo: deviceId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Riddle.fromMap(doc.id, doc.data()))
              .toList(),
        );
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
}
