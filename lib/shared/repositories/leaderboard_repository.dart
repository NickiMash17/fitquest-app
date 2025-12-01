import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/shared/models/leaderboard_entry.dart';
import 'package:fitquest/core/constants/app_constants.dart';

/// Repository for leaderboard data operations
@lazySingleton
class LeaderboardRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  LeaderboardRepository(this._firestore);

  /// Get leaderboard entries
  Future<List<LeaderboardEntry>> getLeaderboard({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('totalXp', descending: true)
          .limit(limit)
          .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        entries.add(LeaderboardEntry(
          userId: doc.id,
          displayName: data['displayName'] ?? 'Anonymous',
          photoUrl: data['photoUrl'],
          totalXp: data['totalXp'] ?? 0,
          currentLevel: data['currentLevel'] ?? 1,
          currentStreak: data['currentStreak'] ?? 0,
          rank: rank++,
        ));
      }

      return entries;
    } catch (e, stackTrace) {
      _logger.e('Error getting leaderboard', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get user rank
  Future<int> getUserRank(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      final userXp = userDoc.data()?['totalXp'] ?? 0;

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('totalXp', isGreaterThan: userXp)
          .count()
          .get();

      return snapshot.count ?? 0 + 1;
    } catch (e, stackTrace) {
      _logger.e('Error getting user rank', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
}

