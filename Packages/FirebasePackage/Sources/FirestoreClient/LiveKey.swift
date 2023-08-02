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
                let config = try documentSnapshot.data(as: Config.self)
                continuation.yield(config)
              } catch {
                continuation.finish(throwing: error)
              }
            }
          }
      }
    }
  )
}
