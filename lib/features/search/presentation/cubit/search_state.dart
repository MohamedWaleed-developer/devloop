import 'package:equatable/equatable.dart';

import '../../../profile/data/models/profile_model.dart';

enum SearchStatus {
  initial,
  loading,
  loaded,
  failure,
}

class SearchState extends Equatable {
  final SearchStatus status;
  final List<ProfileModel> results;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<ProfileModel>? results,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage:
      clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    results,
    errorMessage,
  ];
}