import Dependencies
import God
import AsyncApollo
import Foundation
import Apollo

public extension ApolloClient {
  static let god: ApolloClient = {
    let url = URL(string: "")!
    return ApolloClient(url: url)
  }()
}

public extension GodClient {
  static let liveValue = Self(
    updateUsername: { input in
      let mutation = God.UpdateUsernameMutation(input: input)
      return try await ApolloClient.god.perform(mutation: mutation)
    }
  )
}
