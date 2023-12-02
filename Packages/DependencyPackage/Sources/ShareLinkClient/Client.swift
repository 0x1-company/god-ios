import Dependencies
import DependenciesMacros

@DependencyClient
public struct ShareLinkClient: Sendable {
  public var generateSharedText: @Sendable (_ path: GodAppJpPath, _ source: UtmSource?, _ medium: UtmMedium?) async throws -> String
}

extension ShareLinkClient: TestDependencyKey {
  public static let testValue = Self()
  public static let previewValue = Self()
}

public extension DependencyValues {
  var shareLink: ShareLinkClient {
    get { self[ShareLinkClient.self] }
    set { self[ShareLinkClient.self] = newValue }
  }
}

public extension ShareLinkClient {
  enum GodAppJpPath: String {
    case add
    case invite
  }

  enum UtmSource: String {
    case sms
    case line
    case instagram
    case share
  }

  enum UtmMedium: String {
    case add
    case invite
    case profile
    case onboard
    case requiredInvite = "required_invite"
  }
}
