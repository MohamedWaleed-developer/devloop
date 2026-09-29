import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SocialRemoteDataSource {
  final FirebaseFirestore firestore;

  SocialRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> get followsCollection {
    return firestore.collection('follows');
  }

  String _followId(String followerId, String followingId) {
    return '${followerId}_$followingId';
  }

  Future<void> followUser({
    required String followerId,
    required String followingId,
  }) async {
    if (followerId == followingId) {
      throw Exception('You cannot follow yourself');
    }

    final followId = _followId(
      followerId,
      followingId,
    );

    await followsCollection.doc(followId).set({
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    final followId = _followId(
      followerId,
      followingId,
    );

    await followsCollection.doc(followId).delete();
  }

  Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    final followId = _followId(
      followerId,
      followingId,
    );

    final document = await followsCollection
        .doc(followId)
        .get();

    return document.exists;
  }

  Future<int> getFollowersCount(String userId) async {
    final snapshot = await followsCollection
        .where(
      'followingId',
      isEqualTo: userId,
    )
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<int> getFollowingCount(String userId) async {
    final snapshot = await followsCollection
        .where(
      'followerId',
      isEqualTo: userId,
    )
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}