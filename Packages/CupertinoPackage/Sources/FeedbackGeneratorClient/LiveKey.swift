import Dependencies
import UIKit

extension FeedbackGeneratorClient: DependencyKey {
  public static let liveValue = {
    let generator = UISelectionFeedbackGenerator()
    let impact = UIImpactFeedbackGenerator(style: .medium)
    let notification = UINotificationFeedbackGenerator()

    return Self(
      prepare: { await generator.prepare() },
      impactOccurred: { await impact.impactOccurred() },
      notificationOccurred: { await notification.notificationOccurred($0) }
    )
  }()
}
