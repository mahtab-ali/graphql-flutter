import 'dart:async' show FutureOr;

import 'package:graphql/src/core/graphql_error.dart';

/// The source of the result data contained
///
/// Loading: No data has been specified from any source
/// Cache: A result has been eagerly resolved from the cache
/// OptimisticResults: An optimistic result has been specified
///   (may include eager results from the cache)
/// Network: The query has been resolved on the network
///
/// Both Optimistic and Cache sources are considered "Eager" results
enum QueryResultSource {
  Loading,
  Cache,
  OptimisticResult,
  Network,
}

final eagerSources = {
  QueryResultSource.Cache,
  QueryResultSource.OptimisticResult
};

class QueryResult {
  QueryResult({
    this.data,
    this.errors,
    bool loading,
    bool optimistic,
    QueryResultSource source,
  })  : timestamp = DateTime.now(),
        this.source = source ??
            ((loading == true)
                ? QueryResultSource.Loading
                : (optimistic == true)
                    ? QueryResultSource.OptimisticResult
                    : null);

  DateTime timestamp;

  /// The source of the result data.
  ///
  /// null when unexecuted.
  /// Will be set when encountering an error during any execution attempt
  QueryResultSource source;

  /// List<dynamic> or Map<String, dynamic>
  dynamic data;
  List<GraphQLError> errors;

  /// Whether data has been specified from either the cache or network)
  bool get loading => source == QueryResultSource.Loading;

  /// Whether an optimistic result has been specified
  ///   (may include eager results from the cache)
  bool get optimistic => source == QueryResultSource.OptimisticResult;

  /// Whether the response includes any graphql errors
  bool get hasErrors {
    if (errors == null) {
      return false;
    }

    return errors.isNotEmpty;
  }

  void addError(GraphQLError graphQLError) {
    if (errors != null) {
      errors.add(graphQLError);
    } else {
      errors = <GraphQLError>[graphQLError];
    }
  }
}

class MultiSourceResult {
  MultiSourceResult({
    this.eagerResult,
    this.networkResult,
  }) : assert(
          eagerResult.source != QueryResultSource.Network,
          'An eager result cannot be gotten from the network',
        ) {
    eagerResult ??= QueryResult(loading: true);
  }

  QueryResult eagerResult;
  FutureOr<QueryResult> networkResult;
}
