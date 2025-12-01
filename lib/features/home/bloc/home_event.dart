import 'package:equatable/equatable.dart';

/// Home events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load home data
class HomeDataLoadRequested extends HomeEvent {
  const HomeDataLoadRequested();
}

/// Refresh home data
class HomeDataRefreshRequested extends HomeEvent {
  const HomeDataRefreshRequested();
}

