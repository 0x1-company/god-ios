import CachedAsyncImage
import Styleguide
import SwiftUI

struct ShopItemView: View {
  let id: String
  let name: String
  let description: String?
  let amount: Int
  let imageURL: String
  let action: () -> Void

  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      CachedAsyncImage(
        url: URL(string: imageURL)!,
        content: { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
        },
        placeholder: {
          ProgressView()
            .progressViewStyle(.circular)
        }
      )

      VStack(spacing: 4) {
        Text(name)
          .font(.callout)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundStyle(Color.white)

        if let description {
          Text(description)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.godTextSecondaryDark)
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
        .foregroundStyle(Color.white)
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
    id: "PutYourNameInYourCrushsPoll",
    name: "Put Your Name in Your Crush's Poll",
    description: "Your name remains secret",
    amount: 300,
    imageURL: "https://storage.googleapis.com/god-production.appspot.com/store_items/GET_YOUR_NAME_ON_RANDOM_POLL.png",
    action: {}
  )
}
