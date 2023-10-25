import God
import ProfileImage
import Styleguide
import SwiftUI

public struct FriendsSection: View {
  let friends: [God.FriendFragment]
  let emptyAction: () -> Void
  let action: (God.FriendFragment) -> Void

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Divider()
      Text("Friends", bundle: .module)
        .font(.system(.headline, design: .rounded, weight: .bold))
        .frame(height: 32)
        .padding(.horizontal, 16)

      Divider()

      if friends.isEmpty {
        EmptyView(emptyAction: emptyAction)
      } else {
        ForEach(friends, id: \.self) { friend in
          FriendCard(friend: friend, action: action)
          Divider()
        }
      }
    }
    .background(Color.godWhite)
  }

  struct EmptyView: View {
    let emptyAction: () -> Void
    var body: some View {
      VStack(spacing: 20) {
        Text("You have no friends", bundle: .module)
          .foregroundStyle(Color.godTextSecondaryLight)
          .frame(maxWidth: .infinity)

        Button(action: emptyAction) {
          Text("Add Friends", bundle: .module)
            .frame(height: 56)
            .padding(.horizontal, 48)
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundStyle(.godWhite)
            .overlay(alignment: .leading) {
              Image(.line)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 32, height: 32)
                .clipped()
            }
            .padding(.horizontal, 16)
            .background(Color.godService)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .frame(height: 256)
    }
  }

  struct FriendCard: View {
    let friend: God.FriendFragment
    let action: (God.FriendFragment) -> Void

    var body: some View {
      Button {
        action(friend)
      } label: {
        HStack(alignment: .center, spacing: 12) {
          ProfileImage(
            urlString: friend.imageURL,
            name: friend.firstName,
            size: 40
          )

          Text(friend.displayName.ja)
            .foregroundStyle(Color.godBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 72)
        .padding(.horizontal, 16)
      }
    }
  }
}

#Preview {
  FriendsSection(friends: [], emptyAction: {}, action: { _ in })
    .environment(\.locale, Locale(identifier: "ja-JP"))
}
