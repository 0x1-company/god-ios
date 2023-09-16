import SwiftUI

struct FriendAddCard: View {
  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      Color.red
        .frame(width: 40, height: 40)
        .clipShape(Circle())

      VStack(alignment: .leading) {
        Text("Kevin Ding", bundle: .module)

        Text("1 mutual friend", bundle: .module)
          .foregroundColor(.secondary)
      }

      HStack(spacing: 0) {
        Button("HIDE", action: {})
          .frame(width: 80, height: 34)
          .foregroundColor(.secondary)

        Button("ADD", action: {})
          .frame(width: 80, height: 34)
          .foregroundColor(Color.white)
          .background(Color.orange)
          .clipShape(Capsule())
      }
    }
  }
}

struct FriendAddCardPreviews: PreviewProvider {
  static var previews: some View {
    FriendAddCard()
      .previewLayout(.sizeThatFits)
  }
}
