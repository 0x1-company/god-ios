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
      currentUserAvatar: {
        let query = God.CurrentUserAvatarQuery()
        return apolloClient.watch(query: query)
      },
      currentUserProfile: {
        let query = God.CurrentUserProfileQuery()
        return apolloClient.watch(query: query)
      },
      peopleYouMayKnow: {
        let query = God.PeopleYouMayKnowQuery(first: 20)
        return apolloClient.watch(query: query)
      },
      userSearch: {
        let query = God.UserSearchQuery(username: $0)
        return apolloClient.watch(query: query)
      },
      schools: {
        let query = God.SchoolsQuery(first: 100, after: .null)
        return apolloClient.watch(query: query)
      },
      store: {
        let query = God.StoreQuery()
        return apolloClient.watch(query: query)
      },
      purchase: { input in
        let mutation = God.PurchaseMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      readActivity: {
        let mutation = God.ReadActivityMutation(activityId: $0)
        return try await apolloClient.perform(mutation: mutation)
      },
      activities: {
        let query = God.ActivitiesQuery(after: $0 ?? .null)
        return apolloClient.watch(query: query)
      },
      inboxActivities: {
        let query = God.InboxActivitiesQuery(first: 100, after: .null)
        return apolloClient.watch(query: query)
      },
      inboxActivity: {
        let query = God.InboxActivityQuery(id: $0)
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
      completePoll: { input in
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
      friendRequests: {
        let query = God.FriendRequestsQuery(first: 100)
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
      addPlus: {
        let query = God.AddPlusQuery(first: 300)
        return apolloClient.watch(query: query)
      },
      createFirebaseRegistrationToken: { input in
        let mutation = God.CreateFirebaseRegistrationTokenMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      createContacts: { contacts in
        let mutation = God.CreateContactsMutation(contacts: contacts)
        return try await apolloClient.perform(mutation: mutation)
      },
      createTransaction: {
        let mutation = God.CreateTransactionMutation(transactionId: $0)
        return try await apolloClient.perform(mutation: mutation)
      },
      activeSubscription: {
        let query = God.ActiveSubscriptionQuery()
        return apolloClient.watch(query: query)
      },
      revealFullNameLimit: {
        let query = God.RevealFullNameLimitQuery()
        return apolloClient.watch(query: query)
      },
      revealFullName: { input in
        let mutation = God.RevealFullNameMutation(input: input)
        return try await apolloClient.perform(mutation: mutation)
      },
      banners: {
        let query = God.BannersQuery()
        return apolloClient.watch(query: query)
      },
      clubActivities: {
        let query = God.ClubActivitiesQuery()
        return apolloClient.watch(query: query)
      }
    )
  }
}
