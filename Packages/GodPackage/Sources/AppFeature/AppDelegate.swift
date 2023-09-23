import ComposableArchitecture
import FirebaseAuthClient
import FirebaseCoreClient
import FirebaseMessagingClient
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
  @Dependency(\.firebaseMessaging) var firebaseMessaging

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      return .run { @MainActor send in
        firebaseCore.configure()
        await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            for await event in userNotifications.delegate() {
              await send(.userNotifications(event))
            }
          }
          group.addTask {
            for await _ in firebaseMessaging.delegate() {
              print("for await delegate in firebaseMessaging.delegate()")
              do {
                let token = try await firebaseMessaging.token()
                let input = God.CreateFirebaseRegistrationTokenInput(token: token)
                _ = try await createFirebaseRegistrationToken(input)
              }
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
      return .run { _ in
        #if DEBUG
          firebaseAuth.setAPNSToken(tokenData, .sandbox)
        #else
          firebaseAuth.setAPNSToken(tokenData, .prod)
        #endif
        firebaseMessaging.setAPNSToken(tokenData)
        do {
          let token = try await firebaseMessaging.token()
          let input = God.CreateFirebaseRegistrationTokenInput(token: token)
          _ = try await createFirebaseRegistrationToken(input)
        }
      }

    case let .userNotifications(.willPresentNotification(notification, completionHandler)):
      return .run { _ in
        _ = firebaseMessaging.appDidReceiveMessage(notification.request)
        completionHandler([.list, .sound, .badge, .banner])
      }
      
    case let .userNotifications(.didReceiveResponse(response, completionHandler)):
      return .run { _ in
        _ = firebaseMessaging.appDidReceiveMessage(response.notification.request)
        completionHandler()
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
