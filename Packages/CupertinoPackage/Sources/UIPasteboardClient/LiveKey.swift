import Dependencies
import UIKit

extension UIPasteboardClient: DependencyKey {
  public static let liveValue = Self(
    string: { UIPasteboard.general.string = $0 },
    strings: { UIPasteboard.general.strings = $0 }
  )
}
