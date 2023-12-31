import Styleguide
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
            .font(.system(.body, design: .rounded, weight: .bold))
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
            .font(.system(.title2, design: .rounded, weight: .bold))

          Text("SHOP", bundle: .module)
            .font(.system(.caption, design: .rounded, weight: .bold))
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
            .font(.system(.caption, design: .rounded, weight: .bold))
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

#Preview {
  ShareShopSection(
    coinBalance: 90,
    shareAction: {},
    shopAction: {}
  )
}
