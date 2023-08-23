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

  func interceptors<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> [any ApolloInterceptor] {
      return [
        MaxRetryInterceptor(),
        CacheReadInterceptor(store: self.store),
        FirebaseTokenInterceptor(),
        NetworkFetchInterceptor(client: self.client),
        ResponseCodeInterceptor(),
        MultipartResponseParsingInterceptor(),
        JSONResponseParsingInterceptor(),
        AutomaticPersistedQueryInterceptor(),
        CacheWriteInterceptor(store: self.store),
    ]
  }

  func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
    return nil
  }
}
