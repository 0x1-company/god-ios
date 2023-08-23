import Apollo
import ApolloAPI

class NetworkInterceptorProvider: InterceptorProvider {
  private let store: ApolloStore

  private let client = URLSessionClient()
  private let shouldInvalidateClientOnDeinit = true

  init(store: ApolloStore) {
    self.store = store
  }

  deinit {
    if self.shouldInvalidateClientOnDeinit {
      self.client.invalidate()
    }
  }

  func interceptors(
    for operation: some GraphQLOperation
  ) -> [any ApolloInterceptor] {
    [
      MaxRetryInterceptor(),
      CacheReadInterceptor(store: store),
      FirebaseTokenInterceptor(),
      NetworkFetchInterceptor(client: client),
      ResponseCodeInterceptor(),
      MultipartResponseParsingInterceptor(),
      JSONResponseParsingInterceptor(),
      AutomaticPersistedQueryInterceptor(),
      CacheWriteInterceptor(store: store),
    ]
  }

  func additionalErrorInterceptor(for operation: some GraphQLOperation) -> ApolloErrorInterceptor? {
    nil
  }
}
