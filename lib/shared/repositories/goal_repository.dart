import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/shared/models/goal_model.dart';
import 'package:fitquest/core/constants/app_constants.dart';

/// Repository for goal data operations
@lazySingleton
class GoalRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  GoalRepository(this._firestore);

  /// Convert Firestore Timestamps to ISO8601 strings
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);
    for (final key in [
      'createdAt',
      'updatedAt',
      'startDate',
      'endDate',
      'completedAt'
    ]) {
      if (converted[key] is Timestamp) {
        converted[key] =
            (converted[key] as Timestamp).toDate().toIso8601String();
      } else if (converted[key] == null) {
        converted[key] = null;
      }
    }
    return converted;
  }

  /// Get goals stream for a user
  Stream<List<GoalModel>> getGoalsStream(String userId) {
    return _firestore
        .collection(AppConstants.goalsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GoalModel.fromJson({
          'id': doc.id,
          ..._convertTimestamps(data),
        });
      }).toList();
    });
  }

  /// Get goals for a user
  Future<List<GoalModel>> getGoals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.goalsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GoalModel.fromJson({
          'id': doc.id,
          ..._convertTimestamps(data),
        });
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting goals', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a goal
  Future<String> createGoal(GoalModel goal) async {
    try {
      final docRef =
          await _firestore.collection(AppConstants.goalsCollection).add({
        ...goal.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Goal created: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e('Error creating goal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update a goal
  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection(AppConstants.goalsCollection)
          .doc(goal.id)
          .update({
        ...goal.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Goal updated: ${goal.id}');
    } catch (e, stackTrace) {
      _logger.e('Error updating goal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .delete();
      _logger.i('Goal deleted: $goalId');
    } catch (e, stackTrace) {
      _logger.e('Error deleting goal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, int progress) async {
    try {
      await _firestore
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .update({
        'currentProgress': progress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating goal progress',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
