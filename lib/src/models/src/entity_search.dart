import 'package:aether_core/src/app/app.dart';
import 'package:aether_core/src/entity/entity.dart';

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

extension StringOnEntitySearchExtensions on String {
  Future<SearchResults<T>> apiSearch<T extends Entity>(
      {required SearchParams params,
      required EntityBuilder<T> createEntity}) async {
    final result = await this.api(query: params.queryData).get();
    if (result.hasError) return Future.error(result.errorText);
    return SearchResults<T>(createEntity, searchParams: params)
      ..load(result.body);
  }
}
