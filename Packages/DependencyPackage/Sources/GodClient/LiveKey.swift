import Apollo
import AsyncApollo
import Dependencies
import Foundation
import God

extension GodClient {
  public static func live(apolloClient: @Sendable @escaping () -> ApolloClient) -> Self {
    return Self(
      updateUsername: { input in
        let mutation = God.UpdateUsernameMutation(input: input)
        return try await apolloClient().perform(mutation: mutation)
      },
      store: {
        let query = God.StoreQuery()
        return apolloClient().watch(query: query)
      }
    )
  }
}
