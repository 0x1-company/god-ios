import Apollo
import Build
import Foundation

public extension ApolloClient {
  convenience init(build: Build) {
    let appVersion = build.bundleShortVersion()

    guard let endpoint = build.infoDictionary("endpointURL", for: String.self) else {
      fatalError("")
    }

    let store = ApolloStore()
    let provider = NetworkInterceptorProvider(store: store)
    let requestChainTransport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: URL(string: endpoint)!,
      additionalHeaders: [
        "Content-Type": "application/json",
        "User-Agent": "God/\(appVersion) iOS/16.0",
      ]
    )
    self.init(
      networkTransport: requestChainTransport,
      store: store
    )
  }
}
