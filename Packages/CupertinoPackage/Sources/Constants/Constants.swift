import Foundation
import Dependencies

public struct Constants {
  public var appStoreURL: @Sendable () -> URL
  public var appStoreReviewURL: @Sendable () -> URL
  public var founderURL: @Sendable () -> URL
  public var developerURL: @Sendable () -> URL
}

extension Constants: DependencyKey {
  public static let liveValue: Self = {
    let appId = "6449177523"
    return Self(
      appStoreURL: { URL(string: "https://apps.apple.com/us/app/caaaption/id\(appId)")! },
      appStoreReviewURL: { URL(string: "https://itunes.apple.com/us/app/apple-store/id\(appId)?mt=8&action=write-review")! },
      founderURL: { URL(string: "https://instagram.com/satoya__")! },
      developerURL: { URL(string: "https://instagram.com/tomokisun")! }
    )
  }()
}

extension DependencyValues {
  public var constants: Constants {
    get { self[Constants.self] }
    set { self[Constants.self] = newValue }
  }
}
