part of 'entity.dart';

class GraphQLEntity<T extends Entity> extends GraphQLQuery {
  final T entity;

  GraphQLEntity._(String name, this.entity, List<dynamic> query,
      Map<String, dynamic>? params)
      : super(name, query, params: params);
}
