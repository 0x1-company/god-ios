import Foundation

public struct ServerConfig: Codable, Equatable {
  public let minimumSupportedAppVersion: String
  public let isMaintenance: Bool

  public init(
    minimumSupportedAppVersion: String = "1.0.0",
    isMaintenance: Bool = false
  ) {
    self.minimumSupportedAppVersion = minimumSupportedAppVersion
    self.isMaintenance = isMaintenance
  }
}
