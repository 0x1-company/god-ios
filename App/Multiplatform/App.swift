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
          $0.godClient = .live(authClient: $0.firebaseAuth, build: $0.build)
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
struct CaaaptionApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    WindowGroup {
      AppView(store: appDelegate.store)
    }
  }
}


extension GodClient {
  static func live(authClient: FirebaseAuthClient, build: Build) -> Self {
    return .live(
      apolloClient: {
        let appVersion = build.bundleShortVersion()
        
        let store = ApolloStore()
        let provider = NetworkInterceptorProvider(store: store)
        let url = URL(string: "")!
        let requestChainTransport = RequestChainNetworkTransport(
          interceptorProvider: provider,
          endpointURL: url,
          additionalHeaders: [
            "Content-Type": "application/json",
            "User-Agent": "God/\(appVersion) iOS/16.0",
          ]
        )
        return ApolloClient(
          networkTransport: requestChainTransport,
          store: store
        )
      }
    )
  }
}

class FirebaseTokenInterceptor: ApolloInterceptor {
  var id: String = UUID().uuidString
  private let logger = Logger(subsystem: "jp.godapp", category: "FirebaseTokenInterceptor")

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    Auth.auth().currentUser?.getIDToken(completion: { [weak self] token, error in
      if let error {
        self?.logger.error("\(error.localizedDescription)")
      }
      if let token {
        self?.logger.info("\(token)")
      }
      self?.addTokenAndProceed(
        token ?? "",
        to: request,
        chain: chain,
        response: response,
        completion: completion
      )
    })
  }
  
  private func addTokenAndProceed<Operation: GraphQLOperation>(
    _ token: String,
    to request: HTTPRequest<Operation>,
    chain: RequestChain,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    request.addHeader(name: "Authorization", value: "Bearer \(token)")
    chain.proceedAsync(
      request: request,
      response: response,
      interceptor: self,
      completion: completion
    )
  }
}

class NetworkInterceptorProvider: InterceptorProvider {
  private let store: ApolloStore
  private let client = URLSessionClient()
  private let shouldInvalidateClientOnDeinit = true

  public init(store: ApolloStore) {
    self.store = store
  }

  deinit {
    if self.shouldInvalidateClientOnDeinit {
      self.client.invalidate()
    }
  }

  func interceptors<Operation: GraphQLOperation>(
    for operation: Operation
  ) -> [any ApolloInterceptor] {
      return [
        MaxRetryInterceptor(),
        CacheReadInterceptor(store: self.store),
        FirebaseTokenInterceptor(),
        NetworkFetchInterceptor(client: self.client),
        ResponseCodeInterceptor(),
        MultipartResponseParsingInterceptor(),
        JSONResponseParsingInterceptor(),
        AutomaticPersistedQueryInterceptor(),
        CacheWriteInterceptor(store: self.store),
    ]
  }

  func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
    return nil
  }
}
