import Dependencies
import FirebaseFirestore
import FirebaseFirestoreSwift

extension UserSettingsClient: DependencyKey {
  public static let liveValue = Self(
    contact: { param in
      Firestore.firestore()
        .document("/user_settings/\(param.uid)")
        .setData(["contact": param.status], merge: true)
    },
    notification: { param in
      Firestore.firestore()
        .document("/user_settings/\(param.uid)")
        .setData(["notification": param.status], merge: true)
    }
  )
}
