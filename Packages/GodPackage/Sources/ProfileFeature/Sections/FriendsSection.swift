import ButtonStyles
import Colors
import God
import NameImage
import SwiftUI

public struct FriendsSection: View {
  let friends: [God.FriendFragment]
  let action: (God.FriendFragment) -> Void

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Divider()
      Text("Friends", bundle: .module)
        .font(.headline)
        .bold()
        .frame(height: 32)
        .padding(.horizontal, 16)

      Divider()

      ForEach(friends, id: \.self) { state in
        Button {
          action(state)
        } label: {
          HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: state.imageURL)) { image in
              image
                .resizable()
                .scaledToFill()
                .frame(width: 42, height: 42)
                .clipShape(Circle())
            } placeholder: {
              NameImage(
                familyName: state.lastName,
                givenName: state.firstName
              )
            }

            Text(state.displayName.ja)
              .foregroundStyle(Color.godBlack)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(height: 72)
          .padding(.horizontal, 16)
        }
        Divider()
      }
    }
    .background(Color.godWhite)
  }
}
