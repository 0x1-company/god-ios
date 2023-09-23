import Dependencies
import FirebaseMessaging

extension FirebaseMessagingClient: DependencyKey {
  public static let liveValue = Self(
    delegate: {
      AsyncStream { continuation in
        let delegate = Delegate(continuation: continuation)
        Messaging.messaging().delegate = delegate
        continuation.onTermination = { _ in }
      }
    },
    setAPNSToken: { apnsToken in
      Messaging.messaging().apnsToken = apnsToken
    },
    token: { try await Messaging.messaging().token() },
    appDidReceiveMessage: { request in
      Messaging.messaging().appDidReceiveMessage(request.content.userInfo)
    }
  )
}

extension FirebaseMessagingClient {
  class Delegate: NSObject, MessagingDelegate {
    let continuation: AsyncStream<Void>.Continuation

    init(continuation: AsyncStream<Void>.Continuation) {
      self.continuation = continuation
    }

    func messaging(
      _ messaging: Messaging,
      didReceiveRegistrationToken fcmToken: String?
    ) {
      print("func messaging(_ messaging: Messaging,didReceiveRegistrationToken fcmToken: String?): \(fcmToken ?? "")")
      continuation.yield()
    }
  }
}
