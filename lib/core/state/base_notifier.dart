import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  BaseNotifier() : super(const AsyncLoading()) {
    fetch();
  }

  Future<List<T>> fetchData();

  Future<void> fetch() async {
    state = const AsyncLoading();
    try {
      final results = await fetchData();
      state = AsyncData(results);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
