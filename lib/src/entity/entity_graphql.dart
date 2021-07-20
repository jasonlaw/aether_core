part of 'entity.dart';

class GraphQLEntity<T extends Entity> extends GraphQLQuery {
  final T entity;

  GraphQLEntity._(String name, this.entity, List<dynamic> query,
      Map<String, dynamic>? params, Map<String, String>? paramTypes)
      : super(name, query, params: params, paramTypes: paramTypes);
}
