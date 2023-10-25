import SwiftUI

struct SeeMoreButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(.secondary)
      .frame(height: 50)
      .frame(maxWidth: .infinity, alignment: .center)
  }
}
