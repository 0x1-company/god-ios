import ButtonStyles
import Colors
import SwiftUI

public struct ShareShopSection: View {
  let shareAction: () -> Void
  let shopAction: () -> Void

  public init(
    shareAction: @escaping () -> Void,
    shopAction: @escaping () -> Void
  ) {
    self.shareAction = shareAction
    self.shopAction = shopAction
  }

  public var body: some View {
    HStack(spacing: 16) {
      Button(action: shareAction) {
        HStack(spacing: 8) {
          Text("Share Profile", bundle: .module)
            .bold()
          Image(systemName: "square.and.arrow.up")
        }
        .foregroundColor(.secondary)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .overlay(
          RoundedRectangle(cornerRadius: 52 / 2)
            .stroke(Color.secondary, lineWidth: 1)
        )
      }

      Button(action: shopAction) {
        Text("Shop", bundle: .module)
          .bold()
          .foregroundColor(.secondary)
          .frame(height: 52)
          .frame(maxWidth: .infinity)
          .overlay(
            RoundedRectangle(cornerRadius: 52 / 2)
              .stroke(Color.secondary, lineWidth: 1)
          )
      }
    }
    .frame(height: 84)
    .padding(.horizontal, 16)
    .buttonStyle(HoldDownButtonStyle())
  }
}

struct ShareShopSectionPreviews: PreviewProvider {
  static var previews: some View {
    ShareShopSection(
      shareAction: {},
      shopAction: {}
    )
  }
}
