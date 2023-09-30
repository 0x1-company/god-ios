import Foundation
import FirebaseDynamicLinks

public struct FirebaseDynamicLinkClient {
  public var shouldHandleDynamicLink: @Sendable (URL) -> Bool
  public var dynamicLink: @Sendable (URL) -> DynamicLink?
}
