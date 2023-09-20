import ButtonStyles
import Colors
import God
import NameImage
import SwiftUI

public struct FriendsSection: View {
  let friends: [God.FriendFragment]

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
        HStack(alignment: .center, spacing: 12) {
          NameImage(
            familyName: state.lastName,
            givenName: state.firstName
          )

          Text(state.displayName.ja)
            .frame(maxWidth: .infinity, alignment: .leading)

          Button {
            print("ADDED")
          } label: {
            Text("ADDED", bundle: .module)
              .font(.body)
              .bold()
              .foregroundColor(Color.godTextSecondaryLight)
              .frame(height: 32)
              .padding(.horizontal, 12)
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(Color.godTextSecondaryLight, lineWidth: 1)
              )
          }
        }
        .frame(height: 84)
        .padding(.horizontal, 16)
        Divider()
      }
    }
    .background(Color.godWhite)
  }
}
