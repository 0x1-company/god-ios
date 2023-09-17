import ButtonStyles
import Colors
import God
import SwiftUI

public struct ProfileSection: View {
  let user: God.ProfileSectionFragment
  let editProfile: (() -> Void)?

  var friendsCount: Int {
    user.friendsCount ?? 0
  }

  var username: String {
    "@\(user.username ?? "")"
  }

  public init(
    user: God.ProfileSectionFragment,
    editProfile: (() -> Void)?
  ) {
    self.user = user
    self.editProfile = editProfile
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 16) {
        Color.green
          .frame(width: 90, height: 90)
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 16) {
            Text(friendsCount.description)
              .bold()
              .foregroundColor(.primary)
              +
              Text(" friends", bundle: .module)
              .foregroundColor(.secondary)

            Text("7", bundle: .module)
              .bold()
              .foregroundColor(.primary)
              +
              Text(" stars", bundle: .module)
              .foregroundColor(.secondary)
          }
          if let editProfile {
            Button(action: editProfile) {
              Text("EDIT PROFILE", bundle: .module)
                .bold()
                .foregroundColor(.secondary)
                .frame(width: 120, height: 32)
                .overlay(
                  RoundedRectangle(cornerRadius: 32 / 2)
                    .stroke(Color.secondary, lineWidth: 1)
                )
            }
            .buttonStyle(HoldDownButtonStyle())
          }
        }
      }
      VStack(alignment: .leading, spacing: 4) {
        Text(user.displayName.ja)
          .bold()

        Text(username)
      }
      if let school = user.school {
        HStack(spacing: 16) {
          HStack(spacing: 4) {
            Image(systemName: "house.fill")
            Text(school.shortName)
          }
          HStack(spacing: 4) {
            Image(systemName: "graduationcap.fill")
            Text("9th Grade", bundle: .module)
          }
        }
        .foregroundColor(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
    .background(Color.godWhite)
  }
}
