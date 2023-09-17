import ButtonStyles
import Colors
import SwiftUI

struct ShopItemView: View {
  let name: String
  let description: String?
  let amount: Int
  let action: () -> Void

  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      Color.red
        .frame(width: 60, height: 60)
      VStack(spacing: 4) {
        Text(name)
          .font(.callout)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(Color.white)

        if let description {
          Text(description)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.godGray)
        }
      }

      Button(action: action) {
        HStack(spacing: 4) {
          Text(amount.description)

          Image(.coin)
            .resizable()
            .frame(width: 18, height: 18)
        }
        .frame(width: 76, height: 36)
        .foregroundColor(Color.white)
        .background(Color.godYellow.gradient)
        .clipShape(Capsule())
      }
      .buttonStyle(HoldDownButtonStyle())
    }
    .padding(.horizontal, 16)
    .frame(height: 96)
    .background(Color(uiColor: .secondaryLabel))
    .cornerRadius(16)
  }
}

#Preview {
  ShopItemView(
    name: "Put Your Name in Your Crush's Poll",
    description: "Your name remains secret",
    amount: 300,
    action: {}
  )
}
