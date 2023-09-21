import Apollo
import God

public struct GodClient: Sendable {
  public var updateUsername: @Sendable (God.UpdateUsernameInput) async throws -> God.UpdateUsernameMutation.Data
  public var updateUserProfile: @Sendable (God.UpdateUserProfileInput) async throws -> God.UpdateUserProfileMutation.Data
  public var createUserBlock: @Sendable (God.CreateUserBlockInput) async throws -> God.CreateUserBlockMutation.Data
  public var createUserHide: @Sendable (God.CreateUserHideInput) async throws -> God.CreateUserHideMutation.Data
  public var createUser: @Sendable (God.CreateUserInput) async throws -> God.CreateUserMutation.Data
  public var user: @Sendable (God.UserWhere) -> AsyncThrowingStream<God.UserQuery.Data, Error>
  public var currentUser: @Sendable () -> AsyncThrowingStream<God.CurrentUserQuery.Data, Error>
  public var profile: @Sendable () -> AsyncThrowingStream<God.ProfileQuery.Data, Error>

  public var createFriendRequest: @Sendable (God.CreateFriendRequestInput) async throws -> God.CreateFriendRequestMutation.Data
  public var approveFriendRequest: @Sendable (God.ApproveFriendRequestInput) async throws -> God.ApproveFriendRequestMutation.Data

  public var store: @Sendable () -> AsyncThrowingStream<God.StoreQuery.Data, Error>
  public var purchase: @Sendable (God.PurchaseInput) async throws -> God.PurchaseMutation.Data

  public var readActivity: @Sendable (String) async throws -> God.ReadActivityMutation.Data
  public var activities: @Sendable (String?) -> AsyncThrowingStream<God.ActivitiesQuery.Data, Error>
  public var inboxActivities: @Sendable () -> AsyncThrowingStream<God.InboxActivitiesQuery.Data, Error>

  public var currentPoll: @Sendable () -> AsyncThrowingStream<God.CurrentPollQuery.Data, Error>
  public var createVote: @Sendable (God.CreateVoteInput) async throws -> God.CreateVoteMutation.Data
  public var completePoll: @Sendable (God.CompletePollInput) async throws -> God.CompletePollMutation.Data

  public var friends: @Sendable () -> AsyncThrowingStream<God.FriendsQuery.Data, Error>
  public var friendsOfFriends: @Sendable () -> AsyncThrowingStream<God.FriendsOfFriendsQuery.Data, Error>
  public var fromSchools: @Sendable (String) -> AsyncThrowingStream<God.FromSchoolsQuery.Data, Error>
  public var friendRequests: @Sendable () -> AsyncThrowingStream<God.FriendRequestsQuery.Data, Error>

  public var createFirebaseRegistrationToken: @Sendable (God.CreateFirebaseRegistrationTokenInput) async throws -> God.CreateFirebaseRegistrationTokenMutation.Data

  public var createContacts: @Sendable ([God.ContactInput]) async throws -> God.CreateContactsMutation.Data

  public var createTransaction: @Sendable (String) async throws -> God.CreateTransactionMutation.Data
  public var activeSubscription: @Sendable () -> AsyncThrowingStream<God.ActiveSubscriptionQuery.Data, Error>
  public var revealFullNameLimit: @Sendable () -> AsyncThrowingStream<God.RevealFullNameLimitQuery.Data, Error>
  public var revealFullName: @Sendable (God.RevealFullNameInput) async throws -> God.RevealFullNameMutation.Data
}

public struct GodServerError: Error {
  public let message: String
  public let extensions: [String: Any]
  public var code: GodServerErrorCode? {
    extensions["code"] as? GodServerErrorCode
  }

  public init(
    message: String,
    extensions: [String: Any]
  ) {
    self.message = message
    self.extensions = extensions
  }

  public enum GodServerErrorCode: String {
    case badUserInput = "BAD_USER_INPUT"
    case forbidden = "FORBIDDEN"
    case unauthenticated = "UNAUTHENTICATED"
    case `internal` = "INTERNAL"
    case notInGodMode = "NOT_IN_GOD_MODE"
    case noRevealPermission = "NO_REVEAL_PERMISSION"
  }
}
