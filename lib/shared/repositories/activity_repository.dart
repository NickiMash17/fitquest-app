import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/core/constants/app_constants.dart';
import 'package:fitquest/core/utils/date_utils.dart';

/// Repository for activity data operations
@lazySingleton
class ActivityRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  ActivityRepository(this._firestore);

  /// Convert Firestore Timestamps to ISO8601 strings
  Map<String, dynamic> _convertActivityTimestamps(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);
    if (converted['date'] is Timestamp) {
      converted['date'] =
          (converted['date'] as Timestamp).toDate().toIso8601String();
    }
    return converted;
  }

  /// Get activities stream for user
  Stream<List<ActivityModel>> getActivitiesStream(String userId) {
    try {
      return _firestore
          .collection(AppConstants.activitiesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(50)
          .snapshots()
          .handleError((error) {
        if (error is FirebaseException && error.code == 'failed-precondition') {
          _logger.w(
              'Firestore index not created yet for stream. Returning empty list.',);
        } else {
          _logger.e('Error in activities stream', error: error);
        }
      }).map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return ActivityModel.fromJson({
            'id': doc.id,
            ..._convertActivityTimestamps(data),
          });
        }).toList();
      });
    } catch (e) {
      _logger.e('Error creating activities stream', error: e);
      return Stream.value(<ActivityModel>[]);
    }
  }

  /// Get activities for date range
  Future<List<ActivityModel>> getActivities(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.activitiesCollection)
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ActivityModel.fromJson({
          'id': doc.id,
          ..._convertActivityTimestamps(data),
        });
      }).toList();
    } on FirebaseException catch (e) {
      // Handle index errors gracefully
      if (e.code == 'failed-precondition') {
        _logger.w(
          'Firestore index not created yet. Returning empty list. Create index at: ${e.message}',
        );
        return [];
      }
      _logger.e('Error getting activities', error: e);
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('Error getting activities', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create activity
  Future<String> createActivity(ActivityModel activity) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.activitiesCollection)
          .add(activity.toJson());
      _logger.i('Activity created: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      _logger.e('Error creating activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update activity
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      await _firestore
          .collection(AppConstants.activitiesCollection)
          .doc(activity.id)
          .update(activity.toJson());
      _logger.i('Activity updated: ${activity.id}');
    } catch (e, stackTrace) {
      _logger.e('Error updating activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore
          .collection(AppConstants.activitiesCollection)
          .doc(activityId)
          .delete();
      _logger.i('Activity deleted: $activityId');
    } catch (e, stackTrace) {
      _logger.e('Error deleting activity', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get today's activities
  Future<List<ActivityModel>> getTodayActivities(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateUtils.startOfDay(now);
      final endOfDay = DateUtils.endOfDay(now);
      return await getActivities(
        userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      // If getActivities throws, return empty list
      _logger.w('Error getting today activities, returning empty list: $e');
      return [];
    }
  }
}
