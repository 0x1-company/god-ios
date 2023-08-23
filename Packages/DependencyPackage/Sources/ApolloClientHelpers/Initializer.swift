import Apollo
import Build
import Foundation

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
        "Content-Type": "application/json",
        "User-Agent": "God/\(appVersion) iOS/16.0"
      ]
    )
    self.init(
      networkTransport: requestChainTransport,
      store: store
    )
  }
}
