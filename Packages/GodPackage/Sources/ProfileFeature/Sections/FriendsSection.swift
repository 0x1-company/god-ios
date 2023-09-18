import ButtonStyles
import Colors
import SwiftUI
import God

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
          Circle()
            .fill(Color.blue)
            .frame(width: 48, height: 48)

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

