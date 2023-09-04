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

  var fullName: String {
    "\(user.lastName) \(user.firstName)"
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
              Text(" friends")
              .foregroundColor(.secondary)

            Text("7")
              .bold()
              .foregroundColor(.primary)
              +
              Text(" stars")
              .foregroundColor(.secondary)
          }
          if let editProfile {
            Button(action: editProfile) {
              Text("EDIT PROFILE")
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
        Text(fullName)
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
            Text("9th Grade")
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
