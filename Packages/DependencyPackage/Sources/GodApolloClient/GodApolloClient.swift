import Foundation
import Apollo

public extension ApolloClient {
  static let god: ApolloClient = {
    let url = URL(string: "")!
    return ApolloClient(url: url)
  }()
}
