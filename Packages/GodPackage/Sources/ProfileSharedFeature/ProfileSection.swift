import God
import ProfileImage
import Styleguide
import SwiftUI

public struct ProfileSection: View {
  let imageURL: String
  let friendsCount: Int
  let votedCount: Int
  let username: String
  let firstName: String
  let lastName: String
  let displayName: String
  let schoolShortName: String?
  let grade: String?
  let editProfile: (() -> Void)?

  public init(
    imageURL: String,
    friendsCount: Int,
    votedCount: Int,
    username: String,
    firstName: String,
    lastName: String,
    displayName: String,
    schoolShortName: String?,
    grade: String?,
    editProfile: (() -> Void)? = nil
  ) {
    self.imageURL = imageURL
    self.friendsCount = friendsCount
    self.votedCount = votedCount
    self.username = username
    self.firstName = firstName
    self.lastName = lastName
    self.displayName = displayName
    self.schoolShortName = schoolShortName
    self.grade = grade
    self.editProfile = editProfile
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 16) {
        ProfileImage(
          urlString: imageURL,
          name: firstName,
          size: 90
        )

        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 16) {
            Text(friendsCount.description)
              .foregroundColor(.primary)
              .font(.system(.body, design: .rounded, weight: .bold))
              +
              Text(" friends", bundle: .module)
              .foregroundColor(.secondary)
              .font(.system(.body, design: .rounded))

            Text(votedCount.description)
              .foregroundColor(.primary)
              .font(.system(.body, design: .rounded, weight: .bold))
              +
              Text(" stars", bundle: .module)
              .foregroundColor(.secondary)
              .font(.system(.body, design: .rounded))
          }
          if let editProfile {
            Button(action: editProfile) {
              Text("EDIT PROFILE", bundle: .module)
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(height: 32)
                .padding(.horizontal, 12)
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
        Text(displayName)
          .font(.system(.body, design: .rounded, weight: .bold))

        Text(verbatim: "@\(username)")
      }
      HStack(spacing: 16) {
        if let schoolShortName {
          HStack(spacing: 4) {
            Image(systemName: "house.fill")
            Text(verbatim: schoolShortName)
          }
        }
        if let grade {
          HStack(spacing: 4) {
            Image(systemName: "graduationcap.fill")
            Text(verbatim: grade)
          }
        }
      }
      .foregroundStyle(.secondary)
      .font(.system(.body, design: .rounded))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
    .background(Color.godWhite)
  }
}
