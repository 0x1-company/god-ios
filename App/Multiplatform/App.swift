import AppFeature
import Build
import Apollo
import ApolloAPI
import GodClient
import ComposableArchitecture
import FirebaseAuthClient
import SwiftUI
import FirebaseAuth
import os
import ApolloClientHelpers

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  @Dependency(\.firebaseAuth) var firebaseAuth
  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    AppDelegate.shared.store.send(.sceneDelegate(.shortcutItem(shortcutItem)))
    completionHandler(true)
  }

  func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    for context in URLContexts {
      let url = context.url
      _ = firebaseAuth.canHandle(url)
    }
  }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
  @Dependency(\.firebaseAuth) var firebaseAuth

  static let shared = AppDelegate()
  let store = Store(
    initialState: AppReducer.State(),
    reducer: {
      AppReducer()
        ._printChanges()
        .transformDependency(\.self) {
          $0.godClient = .live(apolloClient: ApolloClient(build: $0.build))
        }
    }
  )

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    store.send(.appDelegate(.didFinishLaunching))

    return true
  }

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    store.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
  }

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    store.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error))))
  }

  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
  ) async -> UIBackgroundFetchResult {
    let result = firebaseAuth.canHandleNotification(userInfo)
    return result ? .noData : .newData
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if firebaseAuth.canHandle(url) {
      return true
    }
    return false
  }

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    store.send(.appDelegate(.configurationForConnecting(options.shortcutItem)))
    let config = UISceneConfiguration(
      name: connectingSceneSession.configuration.name,
      sessionRole: connectingSceneSession.role
    )
    config.delegateClass = SceneDelegate.self
    return config
  }
}

@main
struct GodApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    WindowGroup {
      AppView(store: appDelegate.store)
    }
  }
}
