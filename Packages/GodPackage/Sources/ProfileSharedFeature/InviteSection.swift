import Styleguide
import SwiftUI

public struct InviteSection: View {
  let coinBalance: Int
  let code: String
  let codeCopyAction: () -> Void
  let inviteFriendAction: () -> Void
  let shopAction: () -> Void

  public init(
    coinBalance: Int,
    code: String,
    codeCopyAction: @escaping () -> Void,
    inviteFriendAction: @escaping () -> Void,
    shopAction: @escaping () -> Void
  ) {
    self.coinBalance = coinBalance
    self.code = code
    self.codeCopyAction = codeCopyAction
    self.inviteFriendAction = inviteFriendAction
    self.shopAction = shopAction
  }

  public var body: some View {
    VStack(spacing: 16) {
      VStack(spacing: 16) {
        InviteTicket(code: code)
          .onTapGesture(perform: codeCopyAction)

        Button(action: inviteFriendAction) {
          Label {
            Text("Invite friend", bundle: .module)
          } icon: {
            Image(systemName: "square.and.arrow.up")
          }
          .font(.system(.title3, design: .rounded, weight: .bold))
          .frame(height: 56)
          .frame(maxWidth: .infinity)
          .foregroundStyle(Color.white)
          .background(Color.godBlack)
          .clipShape(Capsule())
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .background(Color.white)
      .cornerRadius(16)

      Button(action: shopAction) {
        HStack(spacing: 8) {
          Text(coinBalance.description)
            .font(.system(.title2, design: .rounded, weight: .bold))
            .foregroundStyle(Color.godBlack)

          Text("SHOP", bundle: .module)
            .font(.system(.caption, design: .rounded, weight: .bold))
            .frame(width: 57, height: 26)
            .foregroundStyle(Color.white)
            .background(Color.godYellow.gradient)
            .clipShape(Capsule())
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: UIColor.secondarySystemBackground))
        .overlay(
          RoundedRectangle(cornerRadius: 52 / 2)
            .stroke(Color.godTextSecondaryLight, lineWidth: 1)
        )
        .overlay(alignment: .top) {
          Text("COINS", bundle: .module)
            .font(.system(.caption, design: .rounded, weight: .bold))
            .padding(.horizontal, 8)
            .foregroundStyle(Color.godTextSecondaryLight)
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .offset(y: -7)
        }
      }
    }
    .padding(.all, 16)
    .background(Color(uiColor: UIColor.secondarySystemBackground))
    .buttonStyle(HoldDownButtonStyle())
  }
}

#Preview {
  InviteSection(
    coinBalance: 100,
    code: "ABCDEF",
    codeCopyAction: {},
    inviteFriendAction: {},
    shopAction: {}
  )
}
