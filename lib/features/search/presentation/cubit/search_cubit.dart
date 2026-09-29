import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/search_repository_impl.dart';
import 'search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchRepositoryImpl repository;

  Timer? _debounce;

  SearchCubit(this.repository)
      : super(const SearchState());

  void search(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(
        const SearchState(
          status: SearchStatus.initial,
        ),
      );
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 350),
          () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        clearError: true,
      ),
    );

    try {
      final results =
      await repository.searchDevelopers(query);

      emit(
        state.copyWith(
          status: SearchStatus.loaded,
          results: results,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}