import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nazokake/model/RiddleModel.dart';
import 'package:nazokake/pages/TimelineScreen.dart';
import 'package:nazokake/util/GetDeviceId.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> addRiddle(String question, String answer) async {
    await _db.collection('riddles').add({
      'question': question,
      'answer': answer,
      'likes': [],
      'timestamp': Timestamp.now(),
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

  Future<void> toggleLike(String riddleId, List<String> currentLikes) async {
    final id = await getDeviceIDweb();
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
