import '../../app/http_client/app_http_client.dart';
import '../../entity/entity.dart' show Entity, EntityBuilder, Field;

class SearchResults {
  late final List data;
  late final PageInfo? pageInfo;

  SearchResults(Map<String, dynamic> map) {
    data = map['results'];
    if (map.containsKey('pageInfo')) {
      final pinfo = map['pageIno'];
      pageInfo = PageInfo(pinfo['endOfPage'], pinfo['totalCount']);
    } else {
      pageInfo = null;
    }
  }

  List<E> of<E extends Entity>(EntityBuilder<E> builder) {
    final result = <E>[];
    for (final item in data) {
      result.add(builder()..load(item));
    }
    return result;
  }

  static GraphQLQuery fragment(List fields) => 'results'.gql(fields);
}

class PageInfo {
  final bool endOfPage;
  final int totalCount;

  PageInfo(this.endOfPage, this.totalCount);

  static GraphQLQuery get fragment =>
      'pageInfo'.gql(['endOfPage', 'totalCount']);
}

class Paging extends Entity {
  Paging({required int size, required int page}) {
    load({'size': size, 'page': page});
  }
}

class SearchParams extends Entity {
  SearchParams() {
    skip.computed(
      bindings: [page, take],
      compute: () => page() * take(),
    );
  }

  Field<int> get page => field('page');
  Field<int> get skip => field('skip');
  Field<int> get take => field('take', defaultValue: 99999);
  Field<String> get orderBy => field('orderBy');

  Map<String, dynamic> get queryData {
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

// @Deprecated('Use SearchResults2')
// class SearchResults<T extends Entity> extends Entity {
//   SearchResults(EntityBuilder<T> createEntity, {required this.searchParams}) {
//     results.register(createEntity);
//   }

//   final SearchParams searchParams;
//   Field<int> get totalCount => field('totalCount');
//   ListField<T> get results => fieldList('results');
// }

// extension AetherStringForEntitySearchExtensions on String {
//   @deprecated
//   Future<SearchResults<T>> apiSearch<T extends Entity>({
//     required SearchParams params,
//     required EntityBuilder<T> createEntity,
//     Map<String, String>? headers,
//     Duration? timeout,
//     bool disableLoadingIndicator = false,
//   }) async {
//     final result = await api(query: params.queryData).get(
//         headers: headers,
//         timeout: timeout,
//         disableLoadingIndicator: disableLoadingIndicator);
//     if (result.hasError) return Future.error(result.errorText);
//     return SearchResults<T>(createEntity, searchParams: params)
//       ..load(result.body);
//   }
// }
