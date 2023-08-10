import Dependencies
import FirebaseFirestore
import FirebaseFirestoreSwift

extension ProfileClient: DependencyKey {
  public static let liveValue: Self = .init(
    user: { uid in
      AsyncThrowingStream { continuation in
        let listener = Firestore.firestore().document("/users/\(uid)")
          .addSnapshotListener { documentSnapshot, error in
            if let error {
              continuation.finish(throwing: error)
            }
            if let documentSnapshot {
              do {
                try continuation.yield(documentSnapshot.data(as: User.self))
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
    isAvailableUsername: { username in
      try await Firestore.firestore().collection("/users")
        .whereField("username", isEqualTo: username)
        .getDocuments()
        .isEmpty
    },
    setDocumentData: { path, data in
      try await Firestore.firestore().document(path).setData(data, merge: true)
    }
  )
}
