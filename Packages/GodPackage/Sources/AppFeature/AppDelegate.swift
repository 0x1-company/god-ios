import ComposableArchitecture
import FirebaseAuthClient
import FirebaseCoreClient
import God
import GodClient
import UIKit
import UserNotificationClient

public struct AppDelegateLogic: Reducer {
  public struct State: Equatable {}
  public enum Action: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(TaskResult<Data>)
    case userNotifications(UserNotificationClient.DelegateEvent)
    case configurationForConnecting(UIApplicationShortcutItem?)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case didFinishLaunching
    }
  }

  @Dependency(\.firebaseCore) var firebaseCore
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.userNotifications) var userNotifications
  @Dependency(\.application.registerForRemoteNotifications) var registerForRemoteNotifications
  @Dependency(\.godClient.createFirebaseRegistrationToken) var createFirebaseRegistrationToken

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      return .run { @MainActor send in
        firebaseCore.configure()
        await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            print("for await event in userNotifications.delegate() {")
            for await event in userNotifications.delegate() {
              await send(.userNotifications(event))
            }
          }
          group.addTask {
            guard try await userNotifications.requestAuthorization([.alert, .sound, .badge])
            else { return }
            await registerForRemoteNotifications()
          }
          group.addTask {
            await send(.delegate(.didFinishLaunching))
          }
        }
      }
    case .didRegisterForRemoteNotifications(.failure):
      return .none

    case let .didRegisterForRemoteNotifications(.success(tokenData)):
      let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
      print("didRegisterForRemoteNotifications: \(token)")
      let input = God.CreateFirebaseRegistrationTokenInput(token: token)
      return .run { _ in
        #if DEBUG
          firebaseAuth.setAPNSToken(tokenData, .sandbox)
        #else
          firebaseAuth.setAPNSToken(tokenData, .prod)
        #endif
        _ = try await createFirebaseRegistrationToken(input)
      }

    case let .userNotifications(.willPresentNotification(_, completionHandler)):
      return .run { _ in
        completionHandler([.list, .sound, .badge, .banner])
      }

    case .userNotifications:
      return .none

    case .configurationForConnecting:
      return .none

    case .delegate:
      return .none
    }
  }
}
