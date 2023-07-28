import SwiftUI

struct SeeMoreButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.secondary)
      .frame(maxWidth: .infinity, alignment: .center)
  }
}
