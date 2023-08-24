import Apollo
import AsyncApollo
import Dependencies
import Foundation
import God

public extension GodClient {
  static func live(apolloClient: ApolloClient) -> Self {
    Self(
      updateUsername: { input in
        let mutation = God.UpdateUsernameMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      updateUserProfile: { input in
        let mutation = God.UpdateUserProfileMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      store: {
        let query = God.StoreQuery()
        return apolloClient.watch(query: query)
      }
    )
  }
}
