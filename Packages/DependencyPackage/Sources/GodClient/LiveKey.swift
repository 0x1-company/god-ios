import Apollo
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
      createUserBlock: { input in
        let mutation = God.CreateUserBlockMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      createUserHide: { input in
        let mutation = God.CreateUserHideMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      createUser: { input in
        let mutation = God.CreateUserMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      user: { userWhere in
        let query = God.UserQuery(where: userWhere)
        return apolloClient.watch(query: query)
      },
      currentUser: {
        let query = God.CurrentUserQuery()
        return apolloClient.watch(query: query)
      },
      createFriendRequest: { input in
        let mutation = God.CreateFriendRequestMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      approveFriendRequest: { input in
        let mutation = God.ApproveFriendRequestMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      store: {
        let query = God.StoreQuery()
        return apolloClient.watch(query: query)
      },
      activities: {
        let query = God.ActivitiesQuery(after: $0 ?? .null)
        return apolloClient.watch(query: query)
      }
    )
  }
}
