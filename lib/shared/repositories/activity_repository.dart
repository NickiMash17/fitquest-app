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
      _logger.i('Loading activities for userId: $userId');
      
      Query query = _firestore
          .collection(AppConstants.activitiesCollection)
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      // Try with orderBy, but fallback without it if index is missing
      QuerySnapshot snapshot;
      List<QueryDocumentSnapshot> sortedDocs;
      try {
        snapshot = await query.orderBy('date', descending: true).get();
        sortedDocs = snapshot.docs.toList();
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          _logger.w('Index missing, trying without orderBy');
          // Try without orderBy
          snapshot = await query.get();
          // Sort manually
          sortedDocs = snapshot.docs.toList();
          sortedDocs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['date'];
            final bDate = (b.data() as Map<String, dynamic>)['date'];
            if (aDate is Timestamp && bDate is Timestamp) {
              return bDate.compareTo(aDate);
            }
            return 0;
          });
        } else {
          rethrow;
        }
      }
      
      _logger.i('Found ${sortedDocs.length} activities in Firestore');
      
      if (sortedDocs.isEmpty) {
        _logger.w('No activities found for userId: $userId');
        return [];
      }
      
      final activities = <ActivityModel>[];
      for (final doc in sortedDocs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          _logger.d('Processing document ${doc.id}, userId in doc: ${data['userId']}');
          
          final converted = _convertActivityTimestamps(data);
          
          // Convert type string back to enum (for JSON serialization)
          if (converted['type'] is String) {
            final typeString = converted['type'] as String;
            try {
              converted['type'] = ActivityType.values.firstWhere(
                (e) => e.name == typeString,
              ).name;
            } catch (e) {
              _logger.w('Unknown activity type: $typeString, defaulting to exercise');
              converted['type'] = ActivityType.exercise.name;
            }
          }
          
          final activity = ActivityModel.fromJson({
            'id': doc.id,
            ...converted,
          });
          
          _logger.d('Created activity model: id=${activity.id}, userId=${activity.userId}, type=${activity.type.name}');
          activities.add(activity);
        } catch (e, stackTrace) {
          _logger.e('Error converting document ${doc.id} to ActivityModel', error: e, stackTrace: stackTrace);
        }
      }
      
      _logger.i('Converted ${activities.length} activities to models');
      _logger.i('Activity IDs: ${activities.map((a) => a.id).toList()}');
      return activities;
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
      // Convert to Firestore-compatible JSON
      final json = activity.toJson();
      _logger.i('Activity JSON: $json');
      
      // Convert DateTime to Timestamp for Firestore
      final firestoreData = <String, dynamic>{};
      
      // Copy all fields
      for (final entry in json.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (key == 'date') {
          if (value is String) {
            firestoreData[key] = Timestamp.fromDate(DateTime.parse(value));
          } else if (value is DateTime) {
            firestoreData[key] = Timestamp.fromDate(value);
          } else {
            firestoreData[key] = value;
          }
        } else if (key == 'createdAt' && value != null) {
          if (value is String) {
            firestoreData[key] = Timestamp.fromDate(DateTime.parse(value));
          } else if (value is DateTime) {
            firestoreData[key] = Timestamp.fromDate(value);
          } else {
            firestoreData[key] = value;
          }
        } else if (key == 'type') {
          // Convert enum to string
          if (value is String) {
            firestoreData[key] = value;
          } else {
            firestoreData[key] = activity.type.name;
          }
        } else {
          firestoreData[key] = value;
        }
      }
      
      _logger.i('Creating activity in Firestore with userId: ${activity.userId}');
      _logger.i('Firestore data keys: ${firestoreData.keys.toList()}');
      
      final docRef = await _firestore
          .collection(AppConstants.activitiesCollection)
          .add(firestoreData);
      
      _logger.i('Activity created successfully in Firestore: ${docRef.id}');
      _logger.i('Activity document path: ${docRef.path}');
      
      // Verify it was saved by reading it back
      final savedDoc = await docRef.get();
      if (savedDoc.exists) {
        _logger.i('Verified: Activity document exists in Firestore');
        final savedData = savedDoc.data();
        _logger.i('Saved document userId: ${savedData?['userId']}');
      } else {
        _logger.e('ERROR: Activity document does not exist after creation!');
      }
      
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
