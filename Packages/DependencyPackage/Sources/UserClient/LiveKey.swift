import Dependencies
import God
import AsyncApollo
import Foundation
import GodApolloClient
import Apollo

public extension UserClient {
  static let liveValue = Self(
    updateUsername: { input in
      let mutation = God.UpdateUsernameMutation(input: input)
      return try await ApolloClient.god.perform(mutation: mutation)
    }
  )
}
