import Styleguide
import Styleguide
import God
import ProfileImage
import SwiftUI

public struct FriendsSection: View {
  let friends: [God.FriendFragment]
  let emptyAction: () -> Void
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

        Button(action: emptyAction) {
          Text("Add Friends", bundle: .module)
            .bold()
            .frame(height: 56)
            .padding(.horizontal, 48)
            .foregroundColor(.godWhite)
            .background(Color.godService)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .frame(height: 256)
      .frame(maxWidth: .infinity)
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
}
