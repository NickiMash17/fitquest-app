import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/shared/models/challenge_model.dart';
import 'package:fitquest/core/constants/app_constants.dart';

/// Repository for challenge data operations
@lazySingleton
class ChallengeRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  ChallengeRepository(this._firestore);

  /// Get daily challenge
  Future<ChallengeModel?> getDailyChallenge() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection(AppConstants.challengesCollection)
          .where('type', isEqualTo: 'daily')
          .where('startDate', isGreaterThanOrEqualTo: startOfDay)
          .where('endDate', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // Create a default daily challenge
        return _createDefaultDailyChallenge();
      }

      final doc = snapshot.docs.first;
      return ChallengeModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    } on FirebaseException catch (e) {
      // Handle index errors gracefully
      if (e.code == 'failed-precondition') {
        _logger.w('Firestore index not created yet. Using default challenge. Create index at: ${e.message}');
        return _createDefaultDailyChallenge();
      }
      _logger.e('Error getting daily challenge', error: e);
      return _createDefaultDailyChallenge();
    } catch (e, stackTrace) {
      _logger.e('Error getting daily challenge', error: e, stackTrace: stackTrace);
      return _createDefaultDailyChallenge();
    }
  }

  /// Create default daily challenge
  ChallengeModel _createDefaultDailyChallenge() {
    final now = DateTime.now();
    return ChallengeModel(
      id: 'default_${now.millisecondsSinceEpoch}',
      title: 'Complete 30 minutes of exercise',
      description: 'Any activity counts! Running, yoga, dancing - you choose.',
      type: ChallengeType.daily,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      targetValue: 30,
      targetUnit: 'minutes',
      xpReward: 50,
    );
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(
    String challengeId,
    int progress,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.challengesCollection)
          .doc(challengeId)
          .update({
        'currentProgress': progress,
        'completed': FieldValue.increment(0), // Will be set based on progress
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating challenge', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

