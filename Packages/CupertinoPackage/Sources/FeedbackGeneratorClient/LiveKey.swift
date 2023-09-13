import Dependencies
import UIKit

extension FeedbackGeneratorClient: DependencyKey {
  public static let liveValue = {
    let generator = UISelectionFeedbackGenerator()
    let hoge = UIImpactFeedbackGenerator.init(style: .medium)
    hoge.impactOccurred()
    return Self(
      prepare: { await generator.prepare() },
      selectionChanged: { await generator.selectionChanged() }
    )
  }()
}
