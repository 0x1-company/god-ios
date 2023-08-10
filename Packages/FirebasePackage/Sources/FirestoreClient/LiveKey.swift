import Dependencies
import FirebaseFirestore
import FirebaseFirestoreSwift

extension FirestoreClient: DependencyKey {
  public static let liveValue: Self = .init(
    config: {
      AsyncThrowingStream { continuation in
        let listener = Firestore.firestore().document("/config/global")
          .addSnapshotListener { documentSnapshot, error in
            if let error {
              continuation.finish(throwing: error)
            }
            if let documentSnapshot {
              do {
                continuation.yield(try documentSnapshot.data(as: Config.self))
              } catch {
                continuation.finish(throwing: error)
              }
            }
          }
        continuation.onTermination = { @Sendable _ in
          listener.remove()
        }
      }
    },
    user: { uid in
      AsyncThrowingStream { continuation in
        let listener = Firestore.firestore().document("/users/\(uid)")
          .addSnapshotListener { documentSnapshot, error in
            if let error {
              continuation.finish(throwing: error)
            }
            if let documentSnapshot {
              do {
                continuation.yield(try documentSnapshot.data(as: User.self))
              } catch {
                continuation.finish(throwing: error)
              }
            }
          }
        continuation.onTermination = { @Sendable _ in
          listener.remove()
        }
      }
    }
  )
}
