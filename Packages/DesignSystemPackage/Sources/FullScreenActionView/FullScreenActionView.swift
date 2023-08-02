import SwiftUI

public struct FullScreenActionView: View {
  let title: LocalizedStringKey
  let actionTitle: LocalizedStringKey
  let action: () -> Void

  public init(
    _ title: LocalizedStringKey,
    actionTitle: LocalizedStringKey,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.actionTitle = actionTitle
    self.action = action
  }

  public var body: some View {
    VStack(spacing: 24) {
      Text(title)
        .font(.title2)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)

      Button(action: action) {
        Text(actionTitle)
          .bold()
          .frame(height: 56)
          .padding(.horizontal, 32)
          .background(Color.white)
          .foregroundColor(Color.black)
          .clipShape(Capsule())
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.orange)
  }
}

struct FullScreenActionViewPreviews: PreviewProvider {
  static var previews: some View {
    FullScreenActionView(
      "Get more\n friends to play",
      actionTitle: "Share the app",
      action: {}
    )
  }
}
