# FitQuest Architecture Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Architecture Layers](#architecture-layers)
4. [State Management](#state-management)
5. [Dependency Injection](#dependency-injection)
6. [Data Flow](#data-flow)
7. [Key Patterns](#key-patterns)
8. [Testing Strategy](#testing-strategy)
9. [Best Practices](#best-practices)
10. [Performance Optimizations](#performance-optimizations)

---

## Architecture Overview

FitQuest follows **Clean Architecture** principles with a **feature-based** folder structure. The app uses a layered architecture that separates concerns and promotes maintainability, testability, and scalability.

### Core Principles
- **Separation of Concerns**: Each layer has a single responsibility
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: Business logic is independent of UI and external dependencies
- **Scalability**: Easy to add new features without affecting existing code

### Technology Stack
- **Framework**: Flutter 3.16.0+
- **Language**: Dart 3.0+
- **State Management**: BLoC (Business Logic Component) Pattern
- **Dependency Injection**: GetIt + Injectable
- **Backend**: Firebase (Auth, Firestore, Storage, Analytics, Crashlytics)
- **Local Storage**: Hive + SharedPreferences
- **Code Generation**: Freezed, Json Serializable, Injectable

---

## Project Structure

```
lib/
├── core/                          # Core functionality shared across features
│   ├── config/                    # Configuration files
│   │   └── firebase_config.dart
│   ├── constants/                # App-wide constants
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   ├── app_gradients.dart
│   │   └── ...
│   ├── di/                        # Dependency injection
│   │   ├── injection.dart
│   │   └── injection.config.dart
│   ├── navigation/               # Navigation configuration
│   │   └── app_router.dart
│   ├── services/                 # Core services
│   │   ├── analytics_service.dart
│   │   ├── cache_service.dart
│   │   ├── connectivity_service.dart
│   │   ├── firestore_cache_service.dart
│   │   └── theme_service.dart
│   ├── theme/                    # Theme configuration
│   │   └── app_theme.dart
│   └── utils/                    # Utility functions
│       ├── color_utils.dart
│       ├── date_utils.dart
│       └── ...
│
├── features/                     # Feature modules (feature-based structure)
│   ├── achievements/
│   │   ├── pages/
│   │   └── widgets/
│   ├── activities/
│   │   ├── bloc/                 # BLoC state management
│   │   │   ├── activity_bloc.dart
│   │   │   ├── activity_event.dart
│   │   │   └── activity_state.dart
│   │   └── pages/
│   ├── authentication/
│   │   ├── bloc/
│   │   └── pages/
│   ├── goals/
│   │   ├── pages/
│   │   └── widgets/
│   ├── home/
│   │   ├── bloc/
│   │   ├── pages/
│   │   └── widgets/
│   └── ...
│
├── shared/                       # Shared code across features
│   ├── models/                   # Data models (Freezed)
│   │   ├── activity_model.dart
│   │   ├── user_model.dart
│   │   └── ...
│   ├── repositories/            # Data repositories
│   │   ├── activity_repository.dart
│   │   ├── user_repository.dart
│   │   └── ...
│   ├── services/                # Business logic services
│   │   ├── plant_service.dart
│   │   ├── xp_calculator_service.dart
│   │   └── ...
│   └── widgets/                 # Reusable widgets
│       ├── premium_button.dart
│       ├── custom_plant_widget.dart
│       └── ...
│
└── main.dart                     # App entry point
```

---

## Architecture Layers

### 1. Presentation Layer (`features/`)
**Responsibility**: UI components, user interactions, and visual representation

**Components**:
- **Pages**: Full-screen UI components (screens)
- **Widgets**: Reusable UI components specific to a feature
- **BLoC**: State management for feature-specific business logic

**Example**:
```dart
// features/activities/pages/add_activity_page.dart
class AddActivityPage extends StatelessWidget {
  // UI implementation
}

// features/activities/bloc/activity_bloc.dart
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  // State management
}
```

### 2. Domain Layer (`shared/services/`)
**Responsibility**: Business logic, domain rules, and calculations

**Components**:
- **Services**: Business logic services (XP calculation, plant evolution, etc.)
- **Models**: Domain models (immutable data structures)

**Example**:
```dart
// shared/services/xp_calculator_service.dart
@lazySingleton
class XpCalculatorService {
  int calculateXp(ActivityModel activity) { ... }
  int calculateLevel(int totalXp) { ... }
}
```

### 3. Data Layer (`shared/repositories/`)
**Responsibility**: Data access, caching, and external API communication

**Components**:
- **Repositories**: Abstract data access layer
- **Models**: Data transfer objects (DTOs) with JSON serialization

**Example**:
```dart
// shared/repositories/activity_repository.dart
@lazySingleton
class ActivityRepository {
  Future<List<ActivityModel>> getActivities(String userId) { ... }
  Future<String> createActivity(ActivityModel activity) { ... }
}
```

### 4. Infrastructure Layer (`core/`)
**Responsibility**: External dependencies, configuration, and utilities

**Components**:
- **Services**: Infrastructure services (analytics, cache, connectivity)
- **Config**: Firebase, app configuration
- **Utils**: Helper functions and utilities

---

## State Management

### BLoC Pattern

FitQuest uses the **BLoC (Business Logic Component)** pattern for state management. BLoC separates business logic from UI and makes the app more testable and maintainable.

#### BLoC Structure

```
Event → BLoC → State → UI
```

**Components**:
1. **Event**: User actions or system events
2. **BLoC**: Business logic processor
3. **State**: UI state representation

#### Example: Activity BLoC

```dart
// Event
abstract class ActivityEvent {}
class ActivitiesLoadRequested extends ActivityEvent {}
class ActivityCreateRequested extends ActivityEvent {
  final ActivityModel activity;
  ActivityCreateRequested(this.activity);
}

// State
abstract class ActivityState {}
class ActivityLoading extends ActivityState {}
class ActivityLoaded extends ActivityState {
  final List<ActivityModel> activities;
  ActivityLoaded(this.activities);
}

// BLoC
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _repository;
  
  ActivityBloc(this._repository) : super(ActivityLoading()) {
    on<ActivitiesLoadRequested>(_onLoadRequested);
    on<ActivityCreateRequested>(_onCreateRequested);
  }
  
  Future<void> _onLoadRequested(
    ActivitiesLoadRequested event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    final activities = await _repository.getActivities(userId);
    emit(ActivityLoaded(activities));
  }
}
```

#### Using BLoC in UI

```dart
BlocBuilder<ActivityBloc, ActivityState>(
  builder: (context, state) {
    if (state is ActivityLoading) {
      return LoadingWidget();
    } else if (state is ActivityLoaded) {
      return ActivitiesList(activities: state.activities);
    }
    return ErrorWidget();
  },
)
```

### Provider Pattern (Theme)

For simple state that doesn't require complex business logic (like theme), we use **Provider**:

```dart
// core/services/theme_service.dart
class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
```

---

## Dependency Injection

### GetIt + Injectable

FitQuest uses **GetIt** for dependency injection with **Injectable** for code generation.

#### Configuration

```dart
// core/di/injection.dart
@InjectableInit()
void configureDependencies() {
  // Register Firebase services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  
  // Register repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt(), getIt()),
  );
  
  // Register services
  getIt.registerLazySingleton<XpCalculatorService>(() => XpCalculatorService());
}
```

#### Using Injectable Annotations

```dart
// Automatically registered with @lazySingleton
@lazySingleton
class XpCalculatorService {
  // Implementation
}

// Dependencies injected automatically
@lazySingleton
class PlantService {
  final XpCalculatorService _xpCalculator;
  
  PlantService(this._xpCalculator); // Auto-injected
}
```

#### Accessing Dependencies

```dart
// In code
final service = getIt<XpCalculatorService>();

// In widgets
final service = getIt<XpCalculatorService>();
```

---

## Data Flow

### Typical Data Flow

```
User Action
    ↓
UI (Page/Widget)
    ↓
Event (BLoC Event)
    ↓
BLoC (Business Logic)
    ↓
Repository (Data Access)
    ↓
Firebase/Local Storage
    ↓
Repository (Data Transformation)
    ↓
BLoC (State Update)
    ↓
State (BLoC State)
    ↓
UI (Rebuild)
```

### Example: Creating an Activity

1. **User taps "Add Activity" button**
   ```dart
   onPressed: () {
     context.read<ActivityBloc>().add(
       ActivityCreateRequested(activity),
     );
   }
   ```

2. **BLoC processes event**
   ```dart
   Future<void> _onCreateRequested(
     ActivityCreateRequested event,
     Emitter<ActivityState> emit,
   ) async {
     emit(ActivityLoading());
     await _repository.createActivity(event.activity);
     await _repository.addXp(userId, xp);
     emit(ActivityCreated());
   }
   ```

3. **Repository saves to Firestore**
   ```dart
   Future<String> createActivity(ActivityModel activity) async {
     final docRef = await _firestore
         .collection('activities')
         .add(activity.toJson());
     return docRef.id;
   }
   ```

4. **UI updates based on state**
   ```dart
   BlocListener<ActivityBloc, ActivityState>(
     listener: (context, state) {
       if (state is ActivityCreated) {
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Activity created!')),
         );
       }
     },
   )
   ```

---

## Key Patterns

### 1. Repository Pattern

Repositories abstract data sources and provide a clean API for data access:

```dart
@lazySingleton
class ActivityRepository {
  final FirebaseFirestore _firestore;
  
  // Get activities from Firestore
  Future<List<ActivityModel>> getActivities(String userId) async {
    final snapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .get();
    
    return snapshot.docs
        .map((doc) => ActivityModel.fromJson(doc.data()))
        .toList();
  }
  
  // Create activity
  Future<String> createActivity(ActivityModel activity) async {
    final docRef = await _firestore
        .collection('activities')
        .add(activity.toJson());
    return docRef.id;
  }
}
```

**Benefits**:
- Single source of truth for data access
- Easy to swap data sources (Firestore → REST API)
- Testable with mock repositories

### 2. Service Pattern

Services contain business logic that doesn't belong to a specific feature:

```dart
@lazySingleton
class XpCalculatorService {
  int calculateXp(ActivityModel activity) {
    switch (activity.type) {
      case ActivityType.exercise:
        return activity.duration * 5;
      // ...
    }
  }
  
  int calculateLevel(int totalXp) {
    return (totalXp / 100).sqrt().floor() + 1;
  }
}
```

### 3. Freezed Models

Immutable data models with code generation:

```dart
@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required String id,
    required String userId,
    required ActivityType type,
    required DateTime date,
    required int duration,
    @Default(0) int xpEarned,
  }) = _ActivityModel;
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
}
```

**Benefits**:
- Immutability (prevents bugs)
- Copy with method for updates
- JSON serialization/deserialization
- Equality comparison

### 4. Widget Composition

Break down complex UIs into smaller, reusable widgets:

```dart
// Large widget broken into smaller pieces
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WelcomeHeader(),
        EnhancedPlantCard(...),
        StatsRow(...),
        QuickActionsSection(...),
      ],
    );
  }
}
```

---

## Testing Strategy

### Unit Tests

Test business logic in isolation:

```dart
// test/services/xp_calculator_service_test.dart
void main() {
  group('XpCalculatorService', () {
    test('calculates XP correctly for exercise', () {
      final service = XpCalculatorService();
      final activity = ActivityModel(
        type: ActivityType.exercise,
        duration: 30,
      );
      
      expect(service.calculateXp(activity), equals(150));
    });
  });
}
```

### Widget Tests

Test UI components:

```dart
testWidgets('displays activity list', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ActivitiesPage(),
    ),
  );
  
  expect(find.text('Activities'), findsOneWidget);
});
```

### BLoC Tests

Test state management:

```dart
blocTest<ActivityBloc, ActivityState>(
  'emits ActivityLoaded when activities are fetched',
  build: () => ActivityBloc(mockRepository),
  act: (bloc) => bloc.add(ActivitiesLoadRequested()),
  expect: () => [
    ActivityLoading(),
    ActivityLoaded([...]),
  ],
);
```

---

## Best Practices

### 1. Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE`

### 2. File Organization

- One class per file (except for related classes)
- Group related files in folders
- Use barrel files (`export`) sparingly

### 3. Error Handling

```dart
try {
  final result = await repository.getData();
  emit(DataLoaded(result));
} on FirebaseException catch (e) {
  emit(DataError(e.message ?? 'Unknown error'));
} catch (e) {
  emit(DataError('Unexpected error: $e'));
}
```

### 4. Code Reusability

- Extract common logic into services
- Create reusable widgets
- Use mixins for shared behavior

### 5. Performance

- Use `const` constructors where possible
- Implement `RepaintBoundary` for expensive widgets
- Cache expensive computations
- Use `ListView.builder` for long lists

---

## Performance Optimizations

### 1. Widget Optimization

- **RepaintBoundary**: Isolate repaints
  ```dart
  RepaintBoundary(
    child: CustomPlantWidget(...),
  )
  ```

- **const constructors**: Reduce rebuilds
  ```dart
  const Text('Hello')
  ```

### 2. Cache Management

- **Firestore Cache**: Limited to 40 MB
- **Memory Cache**: LRU eviction (100 entries)
- **Image Cache**: CachedNetworkImage with cache manager

### 3. Lazy Loading

- **Lazy Singletons**: Created only when first accessed
- **ListView.builder**: Only builds visible items
- **Pagination**: Load data in chunks

### 4. State Management

- **BLoC**: Efficient state updates
- **Selective Rebuilds**: Use `BlocBuilder` with specific states
- **Event Debouncing**: Prevent rapid-fire events

---

## Architecture Decisions

### Why BLoC?

- **Separation of Concerns**: Business logic separate from UI
- **Testability**: Easy to test business logic
- **Predictability**: Clear data flow
- **Reusability**: Business logic can be shared

### Why Repository Pattern?

- **Abstraction**: Hide data source details
- **Testability**: Easy to mock repositories
- **Flexibility**: Can swap data sources easily

### Why Feature-Based Structure?

- **Scalability**: Easy to add new features
- **Maintainability**: Related code grouped together
- **Team Collaboration**: Multiple developers can work on different features

### Why GetIt + Injectable?

- **Type Safety**: Compile-time dependency checking
- **Code Generation**: Reduces boilerplate
- **Performance**: Lazy initialization
- **Testability**: Easy to replace dependencies in tests

---

## Future Improvements

1. **Modular Architecture**: Split into packages for better separation
2. **Riverpod Migration**: Consider migrating from BLoC to Riverpod for simpler state management
3. **Offline-First**: Enhance offline capabilities with local-first architecture
4. **GraphQL**: Consider GraphQL for more efficient data fetching
5. **Microservices**: Split backend into microservices as app grows

---

## Resources

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [BLoC Pattern Documentation](https://bloclibrary.dev/)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Injectable Documentation](https://pub.dev/packages/injectable)

---

**Last Updated**: 2024
**Maintained By**: FitQuest Development Team

