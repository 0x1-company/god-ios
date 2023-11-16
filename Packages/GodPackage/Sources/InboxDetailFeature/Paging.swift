import SwiftUI

extension View {
  @ViewBuilder
  func scrollTargetLayoutIfPossible(isEnabled: Bool = true) -> some View {
    if #available(iOS 17.0, *) {
      self.scrollTargetLayout(isEnabled: isEnabled)
    } else {
      self
    }
  }

  @ViewBuilder
  func scrollTargetBehaviorIfPossible() -> some View {
    if #available(iOS 17.0, *) {
      self.scrollTargetBehavior(.paging)
    } else {
      self
    }
  }
}
