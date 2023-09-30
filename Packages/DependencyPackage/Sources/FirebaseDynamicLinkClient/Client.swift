import Foundation
import FirebaseDynamicLinks

public struct FirebaseDynamicLinkClient {
  public var dynamicLink: @Sendable (URL) async throws -> DynamicLink
}
