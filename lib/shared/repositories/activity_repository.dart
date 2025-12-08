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

    // Helper function to convert any timestamp-like value to ISO8601 string
    String? _convertTimestamp(dynamic value) {
      if (value == null) return null;

      if (value is String) {
        // Already a string, validate it's a valid ISO8601
        try {
          DateTime.parse(value); // Validate it's parseable
          return value;
        } catch (e) {
          _logger.w('Invalid date string format: $value');
          return DateTime.now().toIso8601String();
        }
      }

      if (value is Timestamp) {
        return value.toDate().toIso8601String();
      }

      if (value is DateTime) {
        return value.toIso8601String();
      }

      if (value is Map) {
        // Handle Firestore Timestamp in map format (web)
        if (value.containsKey('_seconds')) {
          try {
            final seconds = value['_seconds'];
            final nanoseconds = value['_nanoseconds'] ?? 0;

            int secs;
            int nanos;

            if (seconds is int) {
              secs = seconds;
            } else if (seconds is String) {
              secs = int.parse(seconds);
            } else {
              _logger.w('Unexpected _seconds type: ${seconds.runtimeType}');
              return DateTime.now().toIso8601String();
            }

            if (nanoseconds is int) {
              nanos = nanoseconds;
            } else if (nanoseconds is String) {
              nanos = int.parse(nanoseconds);
            } else {
              nanos = 0;
            }

            final milliseconds = secs * 1000 + (nanos ~/ 1000000);
            return DateTime.fromMillisecondsSinceEpoch(milliseconds)
                .toIso8601String();
          } catch (e, stackTrace) {
            _logger.e('Error converting Map Timestamp',
                error: e, stackTrace: stackTrace);
            return DateTime.now().toIso8601String();
          }
        }
      }

      // Last resort: try to convert to string and parse
      _logger
          .w('Unexpected timestamp type: ${value.runtimeType}, value: $value');
      try {
        return DateTime.parse(value.toString()).toIso8601String();
      } catch (e) {
        _logger.e('Failed to parse timestamp: $value', error: e);
        return DateTime.now().toIso8601String();
      }
    }

    // Convert date field
    final dateConverted = _convertTimestamp(converted['date']);
    if (dateConverted != null) {
      converted['date'] = dateConverted;
    } else {
      // If date is null, set a default
      converted['date'] = DateTime.now().toIso8601String();
      _logger.w('Date field was null, using current date');
    }

    // Convert createdAt field if it exists
    final createdAtConverted = _convertTimestamp(converted['createdAt']);
    if (createdAtConverted != null) {
      converted['createdAt'] = createdAtConverted;
    }
    // If createdAt is null, that's okay - it's optional

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
            'Firestore index not created yet for stream. Returning empty list.',
          );
        } else {
          _logger.e('Error in activities stream', error: error);
        }
      }).map((snapshot) {
        final activities = <ActivityModel>[];
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            _logger.d(
                'Stream: Processing document ${doc.id}, userId in doc: ${data['userId']}');

            // Convert timestamps first
            final converted = _convertActivityTimestamps(data);

            // Validate required fields before parsing
            if (converted['date'] == null || converted['date'] is! String) {
              _logger.e(
                  'Stream: Document ${doc.id} has invalid or missing date field');
              continue; // Skip this document
            }

            // Validate createdAt if present
            if (converted['createdAt'] != null &&
                converted['createdAt'] is! String) {
              _logger.w(
                  'Stream: Document ${doc.id} has invalid createdAt type after conversion: ${converted['createdAt']?.runtimeType}');
              try {
                dynamic createdAtValue = converted['createdAt'];
                if (createdAtValue is Timestamp) {
                  converted['createdAt'] =
                      createdAtValue.toDate().toIso8601String();
                } else if (createdAtValue is DateTime) {
                  converted['createdAt'] = createdAtValue.toIso8601String();
                } else {
                  converted.remove('createdAt');
                }
              } catch (e) {
                converted.remove('createdAt');
              }
            }

            // Validate type
            if (converted['type'] == null) {
              converted['type'] = ActivityType.exercise.name;
            } else if (converted['type'] is String) {
              final typeString = converted['type'] as String;
              try {
                ActivityType.values.firstWhere((e) => e.name == typeString);
              } catch (e) {
                converted['type'] = ActivityType.exercise.name;
              }
            } else {
              converted['type'] = ActivityType.exercise.name;
            }

            // Validate userId
            if (converted['userId'] == null || converted['userId'] is! String) {
              _logger.e('Stream: Document ${doc.id} has invalid userId field');
              continue; // Skip this document
            }

            // Now try to parse the activity
            final activity = ActivityModel.fromJson({
              'id': doc.id,
              ...converted,
            });

            activities.add(activity);
          } catch (e, stackTrace) {
            _logger.e(
                'Stream: Error converting document ${doc.id} to ActivityModel',
                error: e,
                stackTrace: stackTrace);
            // Continue with next document instead of failing completely
          }
        }
        return activities;
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
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
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
      _logger.i('Query userId filter: $userId');

      if (sortedDocs.isEmpty) {
        _logger.w('No activities found for userId: $userId');
        return [];
      }

      final activities = <ActivityModel>[];
      for (final doc in sortedDocs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final docUserId = data['userId'];
          _logger.d(
              'Processing document ${doc.id}, userId in doc: $docUserId (expected: $userId)');

          // Double-check userId matches (should already be filtered by query, but verify)
          if (docUserId != userId) {
            _logger.w(
                'Document ${doc.id} has userId mismatch: $docUserId != $userId, skipping');
            continue;
          }

          // Convert timestamps first
          final converted = _convertActivityTimestamps(data);

          // Validate required fields before parsing
          if (converted['date'] == null || converted['date'] is! String) {
            _logger.e('Document ${doc.id} has invalid or missing date field');
            _logger.e(
                'Date value: ${converted['date']}, type: ${converted['date']?.runtimeType}');
            continue; // Skip this document
          }

          // Validate createdAt if present - it should already be converted by _convertActivityTimestamps
          if (converted['createdAt'] != null &&
              converted['createdAt'] is! String) {
            _logger.w(
                'Document ${doc.id} has invalid createdAt type after conversion: ${converted['createdAt']?.runtimeType}');
            // Try to manually convert it
            try {
              dynamic createdAtValue = converted['createdAt'];
              if (createdAtValue is Timestamp) {
                converted['createdAt'] =
                    createdAtValue.toDate().toIso8601String();
              } else if (createdAtValue is DateTime) {
                converted['createdAt'] = createdAtValue.toIso8601String();
              } else {
                // Remove invalid createdAt - it's optional
                converted.remove('createdAt');
                _logger.w(
                    'Removed invalid createdAt field from document ${doc.id}');
              }
            } catch (e) {
              // Remove invalid createdAt - it's optional
              converted.remove('createdAt');
              _logger.w(
                  'Removed invalid createdAt field from document ${doc.id} due to error: $e');
            }
          }

          // Validate and convert type
          if (converted['type'] == null) {
            _logger.w(
                'Document ${doc.id} has no type field, defaulting to exercise');
            converted['type'] = ActivityType.exercise.name;
          } else if (converted['type'] is String) {
            final typeString = converted['type'] as String;
            try {
              // Validate the type exists
              ActivityType.values.firstWhere((e) => e.name == typeString);
              // Keep as string for JSON serialization
            } catch (e) {
              _logger.w(
                  'Unknown activity type: $typeString, defaulting to exercise');
              converted['type'] = ActivityType.exercise.name;
            }
          } else {
            _logger.w(
                'Document ${doc.id} has invalid type field, defaulting to exercise');
            converted['type'] = ActivityType.exercise.name;
          }

          // Validate userId
          if (converted['userId'] == null || converted['userId'] is! String) {
            _logger.e('Document ${doc.id} has invalid userId field');
            continue; // Skip this document
          }

          // Now try to parse the activity
          final activity = ActivityModel.fromJson({
            'id': doc.id,
            ...converted,
          });

          _logger.d(
              'Created activity model: id=${activity.id}, userId=${activity.userId}, type=${activity.type.name}');
          activities.add(activity);
        } catch (e, stackTrace) {
          _logger.e('Error converting document ${doc.id} to ActivityModel',
              error: e, stackTrace: stackTrace);
          _logger.e('Document data: ${doc.data()}');
          // Continue with next document instead of failing completely
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

      _logger
          .i('Creating activity in Firestore with userId: ${activity.userId}');
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

  /// Get a single activity by ID
  Future<ActivityModel?> getActivityById(String activityId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.activitiesCollection)
          .doc(activityId)
          .get();

      if (!doc.exists) {
        _logger.w('Activity document $activityId does not exist');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        _logger.w('Activity document $activityId has null data');
        return null;
      }

      final converted = _convertActivityTimestamps(data);

      // Validate required fields
      if (converted['date'] == null || converted['date'] is! String) {
        _logger.e('Activity $activityId has invalid date field');
        return null;
      }

      // Validate and convert type
      if (converted['type'] == null) {
        converted['type'] = ActivityType.exercise.name;
      } else if (converted['type'] is String) {
        final typeString = converted['type'] as String;
        try {
          ActivityType.values.firstWhere((e) => e.name == typeString);
        } catch (e) {
          converted['type'] = ActivityType.exercise.name;
        }
      } else {
        converted['type'] = ActivityType.exercise.name;
      }

      // Validate userId
      if (converted['userId'] == null || converted['userId'] is! String) {
        _logger.e('Activity $activityId has invalid userId field');
        return null;
      }

      return ActivityModel.fromJson({
        'id': doc.id,
        ...converted,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting activity by ID',
          error: e, stackTrace: stackTrace);
      return null;
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
