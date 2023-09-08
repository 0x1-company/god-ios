import UIKit

public struct UIApplicationClient {
  public var openSettingsURLString: @Sendable () async -> String
  public var openNotificationSettingsURLString: @Sendable () async -> String
}
