import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/shared/models/leaderboard_entry.dart';
import 'package:fitquest/core/constants/app_constants.dart';

const Duration _kLeaderboardCacheDuration = Duration(seconds: 30);

/// Repository for leaderboard data operations
@lazySingleton
class LeaderboardRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();
  List<LeaderboardEntry>? _cachedLeaderboard;
  DateTime? _cachedAt;

  LeaderboardRepository(this._firestore);

  /// Get leaderboard entries
  Future<List<LeaderboardEntry>> getLeaderboard({
    int limit = 20,
    int? startAfterXp,
  }) async {
    // Return cached leaderboard if fresh
    if (_cachedLeaderboard != null && _cachedAt != null) {
      if (DateTime.now().difference(_cachedAt!) < _kLeaderboardCacheDuration) {
        _logger.d('Returning cached leaderboard');
        return _cachedLeaderboard!;
      }
    }
    try {
      Query query = _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('totalXp', descending: true)
          .limit(limit);
      if (startAfterXp != null) {
        query = query.startAfter([startAfterXp]);
      }
      final snapshot = await query.get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        entries.add(LeaderboardEntry(
          userId: doc.id,
          displayName: data['displayName'] as String? ?? 'Anonymous',
          photoUrl: data['photoUrl'] as String?,
          totalXp: (data['totalXp'] as int?) ?? 0,
          currentLevel: (data['currentLevel'] as int?) ?? 1,
          currentStreak: (data['currentStreak'] as int?) ?? 0,
          rank: rank++,
        ));
      }

      if (startAfterXp == null) {
        // Only cache the first page results
        _cachedLeaderboard = entries;
        _cachedAt = DateTime.now();
      }
      return entries;
    } catch (e, stackTrace) {
      _logger.e('Error getting leaderboard', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Clear cache explicitly
  void clearCache() {
    _cachedLeaderboard = null;
    _cachedAt = null;
  }

  /// Get user rank
  Future<int> getUserRank(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      final userData = userDoc.data();
      final userXp = (userData?['totalXp'] as int?) ?? 0;

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
