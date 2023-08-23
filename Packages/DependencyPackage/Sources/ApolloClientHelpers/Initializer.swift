import Apollo
import Build

extension ApolloClient {
  public convenience init(build: Build) {
    let appVersion = build.bundleShortVersion()
    
    let store = ApolloStore()
    let provider = NetworkInterceptorProvider(store: store)
    let url = URL(string: "")!
    let requestChainTransport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: url,
      additionalHeaders: [
      ]
    )
    self.init(
      networkTransport: requestChainTransport,
      store: store
    )
  }
}
