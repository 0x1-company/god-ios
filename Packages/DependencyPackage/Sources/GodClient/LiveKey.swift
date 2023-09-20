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
      profile: {
        let query = God.ProfileQuery()
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
      purchase: { input in
        let mutation = God.PurchaseMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      activities: {
        let query = God.ActivitiesQuery(after: $0 ?? .null)
        return apolloClient.watch(query: query)
      },
      currentPoll: {
        let query = God.CurrentPollQuery()
        return apolloClient.watch(query: query)
      },
      createVote: { input in
        let mutation = God.CreateVoteMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      completePoll: {input in
        let mutation = God.CompletePollMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      friends: {
        let query = God.FriendsQuery()
        return apolloClient.watch(query: query)
      },
      friendsOfFriends: {
        let query = God.FriendsOfFriendsQuery(first: 100, after: .null)
        return apolloClient.watch(query: query)
      },
      fromSchools: { schoolId in
        let query = God.FromSchoolsQuery(schoolId: schoolId, first: 100, after: .null)
        return apolloClient.watch(query: query)
      },
      friendRequests: {
        let query = God.FriendRequestsQuery(first: 100)
        return apolloClient.watch(query: query)
      },
      createFirebaseRegistrationToken: { input in
        let mutation = God.CreateFirebaseRegistrationTokenMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      createContacts: { contacts in
        let mutation = God.CreateContactsMutation(contacts: contacts)
        return try await apolloClient.perform(mutation: mutation)
      }
    )
  }
}
