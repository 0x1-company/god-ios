import Dependencies
import FirebaseFirestore
import FirebaseFirestoreSwift

extension DeleteAccountReasonClient: DependencyKey {
  public static let liveValue = Self(
    insert: { param in
      Firestore.firestore()
        .collection("delete_account_reasons")
        .document()
        .setData([
          "uid": param.uid,
          "reasons": param.reasons
        ])
    }
  )
}
