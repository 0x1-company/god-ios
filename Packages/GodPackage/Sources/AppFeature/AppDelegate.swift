import ComposableArchitecture
import FirebaseAuthClient
import FirebaseCoreClient
import UIKit
import God
import GodClient

public struct AppDelegateLogic: Reducer {
  public struct State: Equatable {}
  public enum Action: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(TaskResult<Data>)
    case configurationForConnecting(UIApplicationShortcutItem?)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case didFinishLaunching
    }
  }

  @Dependency(\.firebaseCore) var firebaseCore
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.godClient.createFirebaseRegistrationToken) var createFirebaseRegistrationToken

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      return .run { @MainActor send in
        firebaseCore.configure()
        send(.delegate(.didFinishLaunching))
      }
    case .didRegisterForRemoteNotifications(.failure):
      return .none

    case let .didRegisterForRemoteNotifications(.success(tokenData)):
      let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
      let input = God.CreateFirebaseRegistrationTokenInput(token: token)
      return .run { _ in
        firebaseAuth.setAPNSToken(tokenData, .sandbox)
        _ = try await createFirebaseRegistrationToken(input)
      }
    case .configurationForConnecting:
      return .none

    case .delegate:
      return .none
    }
  }
}
