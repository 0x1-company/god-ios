import Apollo
import AsyncApollo
import Dependencies
import Foundation
import God

public extension ApolloClient {
  static let god: ApolloClient = {
    let url = URL(string: "")!
    return ApolloClient(url: url)
  }()
}

extension GodClient: DependencyKey {
  public static let liveValue = Self(
    updateUsername: { input in
      let mutation = God.UpdateUsernameMutation(input: input)
      return try await ApolloClient.god.perform(mutation: mutation)
    },
    store: {
      let query = God.StoreQuery()
      return ApolloClient.god.watch(query: query)
    }
  )
}
