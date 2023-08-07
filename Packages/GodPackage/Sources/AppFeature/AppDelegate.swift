import ComposableArchitecture
import FirebaseCoreClient
import UIKit
import FirebaseAuthClient

public struct AppDelegateReducer: Reducer {
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
      return .run { send in
        firebaseCore.configure()
        await send(.delegate(.didFinishLaunching))
      }
    case .didRegisterForRemoteNotifications(.failure):
      return .none

    case let .didRegisterForRemoteNotifications(.success(deviceToken)):
      return .run { _ in
        self.firebaseAuth.setAPNSToken(deviceToken, .sandbox)
      }
    case .configurationForConnecting:
      return .none

    case .delegate:
      return .none
    }
  }
}
