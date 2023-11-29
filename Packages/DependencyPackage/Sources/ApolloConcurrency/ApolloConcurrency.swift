import Apollo
import ApolloAPI
import Foundation

public extension ApolloClient {
  func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy = .returnCacheDataAndFetch,
    contextIdentifier: UUID? = nil,
    callbackQueue: DispatchQueue = .main
  ) -> AsyncThrowingStream<Query.Data, Error> {
    AsyncThrowingStream { continuation in
      let watcher = watch(
        query: query,
        cachePolicy: cachePolicy,
        callbackQueue: callbackQueue
      ) { result in
        switch result {
        case let .success(response):
          if let data = response.data {
            continuation.yield(data)
          } else if let error = response.errors?.last {
            continuation.yield(with: .failure(GodServerError(error: error)))
          } else {
            continuation.finish(throwing: nil)
          }
        case let .failure(error):
          continuation.finish(throwing: error)
        }
      }
      continuation.onTermination = { @Sendable _ in
        watcher.cancel()
      }
    }
  }

  func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    publishResultToStore: Bool = true,
    queue: DispatchQueue = .main
  ) async throws -> Mutation.Data {
    try await withCheckedThrowingContinuation { continuation in
      perform(
        mutation: mutation,
        publishResultToStore: publishResultToStore,
        queue: queue,
        resultHandler: { result in
          switch result {
          case let .success(response):
            if let data = response.data {
              continuation.resume(returning: data)
            }
            if let error = response.errors?.last {
              continuation.resume(throwing: GodServerError(error: error))
            }
          case let .failure(error):
            continuation.resume(throwing: error)
          }
        }
      )
    }
  }
}

public extension GodServerError {
  init(error: GraphQLError) {
    self.init(
      message: error.message ?? "",
      extensions: error.extensions ?? [:]
    )
  }
}
