import ComposableArchitecture
import FirebaseAuthClient
import FirebaseCoreClient
import UIKit

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

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      return .run { @MainActor send in
        firebaseCore.configure()
        send(.delegate(.didFinishLaunching))
      }
    case .didRegisterForRemoteNotifications(.failure):
      return .none

    case let .didRegisterForRemoteNotifications(.success(deviceToken)):
      return .run { _ in
        firebaseAuth.setAPNSToken(deviceToken, .sandbox)
      }
    case .configurationForConnecting:
      return .none

    case .delegate:
      return .none
    }
  }
}
