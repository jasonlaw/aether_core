import '../../app/app.dart';
import '../../entity/entity.dart';

class SearchParams extends Entity {
  SearchParams() {
    skip.computed(
      bindings: [page, take],
      compute: () => page() * take(),
    );
  }

  Field<int> get page => field("page");
  Field<int> get skip => field("skip");
  Field<int> get take => field("take", defaultValue: 99999);
  Field<String> get orderBy => field("orderBy");

  Map<String, dynamic> get queryData {
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class SearchResults<T extends Entity> extends Entity {
  SearchResults(EntityBuilder<T> createEntity, {required this.searchParams}) {
    results.register(createEntity);
  }

  final SearchParams searchParams;
  Field<int> get totalCount => field("totalCount");
  ListField<T> get results => fieldList("results");
}

extension AetherStringForEntitySearchExtensions on String {
  Future<SearchResults<T>> apiSearch<T extends Entity>({
    required SearchParams params,
    required EntityBuilder<T> createEntity,
    Map<String, String>? headers,
    Duration? timeout,
    bool disableLoadingIndicator = false,
  }) async {
    final result = await api(query: params.queryData).get(
        headers: headers,
        timeout: timeout,
        disableLoadingIndicator: disableLoadingIndicator);
    if (result.hasError) return Future.error(result.errorText);
    return SearchResults<T>(createEntity, searchParams: params)
      ..load(result.body);
  }
}
