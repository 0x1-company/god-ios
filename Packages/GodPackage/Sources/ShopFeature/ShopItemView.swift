import SwiftUI

struct ShopItemView: View {
  let name: String
  let description: String?
  let amount: Int

  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      Color.red
        .frame(width: 60, height: 60)
      VStack(spacing: 0) {
        Text(name)
          .font(.callout)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(Color.white)

        if let description = description {
          Text(description)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color.gray)
        }
      }

      Button(action: {}) {
        Text(amount.description)
          .frame(width: 76, height: 36)
          .foregroundColor(Color.white)
          .background(Color.yellow.gradient)
          .clipShape(Capsule())
      }
    }
    .padding(.horizontal, 16)
    .frame(height: 96)
    .background(Color(uiColor: .secondaryLabel))
    .cornerRadius(16)
  }
}

struct ShopItemViewPreviews: PreviewProvider {
  static var previews: some View {
    Group {
      ShopItemView(
        name: "Get Your Name on 3 Random Polls",
        description: nil,
        amount: 100
      )
      ShopItemView(
        name: "Put Your Name in Your Crush's Poll",
        description: "Your name remains secret",
        amount: 300
      )
    }
    .previewLayout(.sizeThatFits)
  }
}
