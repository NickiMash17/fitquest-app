import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/core/constants/app_constants.dart';

/// Repository for user data operations
@lazySingleton
class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Logger _logger = Logger();

  UserRepository(this._firestore, this._auth);

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get user stream
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data()!;
      return UserModel.fromJson({
        'id': snapshot.id,
        ..._convertTimestamps(data),
      });
    });
  }

  /// Get user by ID with retry logic for offline scenarios
  Future<UserModel?> getUser(String userId) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        _logger.d(
            'Fetching user: $userId (attempt ${retryCount + 1}/$maxRetries)');
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .get(const GetOptions(source: Source.serverAndCache));

        if (!doc.exists) {
          _logger.w('User document does not exist: $userId');
          return null;
        }
        final data = doc.data();
        if (data == null) {
          _logger.w('User document has no data: $userId');
          return null;
        }
        _logger.d('User data retrieved, converting...');
        final convertedData = _convertTimestamps(data);
        final user = UserModel.fromJson({
          'id': doc.id,
          ...convertedData,
        });
        _logger.d('User model created successfully: ${user.displayName}');
        return user;
      } on FirebaseException catch (e, stackTrace) {
        // Handle offline/unavailable errors with retry
        if ((e.code == 'unavailable' || e.code == 'deadline-exceeded') &&
            retryCount < maxRetries - 1) {
          retryCount++;
          final delay = Duration(seconds: retryCount);
          _logger
              .w('Firestore unavailable, retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          continue;
        }
        _logger.e('Error getting user: $userId',
            error: e, stackTrace: stackTrace);
        rethrow;
      } catch (e, stackTrace) {
        _logger.e('Error getting user: $userId',
            error: e, stackTrace: stackTrace);
        rethrow;
      }
    }
    return null;
  }

  /// Convert Firestore Timestamps to ISO8601 strings
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);
    for (final key in ['createdAt', 'updatedAt', 'lastActivityDate']) {
      if (converted[key] is Timestamp) {
        converted[key] =
            (converted[key] as Timestamp).toDate().toIso8601String();
      } else if (converted[key] == null) {
        converted[key] = null;
      }
    }
    return converted;
  }

  /// Create user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());
      _logger.i('User created: ${user.id}');
    } catch (e, stackTrace) {
      _logger.e('Error creating user', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update({
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('User updated: ${user.id}');
    } catch (e, stackTrace) {
      _logger.e('Error updating user', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Add XP to user
  Future<void> addXp(String userId, int xp) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'totalXp': FieldValue.increment(xp),
        'plantCurrentXp': FieldValue.increment(xp),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error adding XP', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update streak
  Future<void> updateStreak(String userId, int streak) async {
    try {
      final userRef =
          _firestore.collection(AppConstants.usersCollection).doc(userId);
      final userDoc = await userRef.get();
      final currentLongestStreak =
          userDoc.data()?['longestStreak'] as int? ?? 0;

      await userRef.update({
        'currentStreak': streak,
        'longestStreak':
            streak > currentLongestStreak ? streak : currentLongestStreak,
        'lastActivityDate': FieldValue.serverTimestamp(),
        'plantHealth': 100, // Reset health to 100 when activity is logged
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating streak', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update plant health (called periodically to decay health)
  Future<void> updatePlantHealth(String userId, int health) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'plantHealth': health.clamp(0, 100),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating plant health',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update plant evolution stage
  Future<void> updatePlantEvolutionStage(String userId, int stage) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'plantEvolutionStage': stage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating plant evolution stage',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update plant name
  Future<void> updatePlantName(String userId, String? plantName) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'plantName': plantName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Plant name updated for user: $userId');
    } catch (e, stackTrace) {
      _logger.e('Error updating plant name', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
