import ButtonStyles
import Colors
import SwiftUI

public struct ShareShopSection: View {
  let coinBalance: Int
  let shareAction: () -> Void
  let shopAction: () -> Void

  public init(
    coinBalance: Int,
    shareAction: @escaping () -> Void,
    shopAction: @escaping () -> Void
  ) {
    self.coinBalance = coinBalance
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
        .foregroundStyle(Color.godTextSecondaryLight)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .overlay(
          RoundedRectangle(cornerRadius: 52 / 2)
            .stroke(Color.godTextSecondaryLight, lineWidth: 1)
        )
      }

      Button(action: shopAction) {
        HStack(spacing: 8) {
          Text(coinBalance.description)
            .bold()
            .font(.title2)

          Text("SHOP")
            .bold()
            .font(.caption)
            .frame(width: 57, height: 26)
            .foregroundStyle(Color.white)
            .background(Color.godYellow.gradient)
            .clipShape(Capsule())
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .overlay(
          RoundedRectangle(cornerRadius: 52 / 2)
            .stroke(Color.godTextSecondaryLight, lineWidth: 1)
        )
        .overlay(alignment: .top) {
          Text("COINS", bundle: .module)
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .foregroundStyle(Color.godTextSecondaryLight)
            .background(Color.godBackgroundWhite)
            .offset(y: -7)
        }
      }
    }
    .frame(height: 84)
    .padding(.horizontal, 16)
    .buttonStyle(HoldDownButtonStyle())
    .background(Color.godBackgroundWhite)
  }
}

struct ShareShopSectionPreviews: PreviewProvider {
  static var previews: some View {
    ShareShopSection(
      coinBalance: 90,
      shareAction: {},
      shopAction: {}
    )
  }
}
