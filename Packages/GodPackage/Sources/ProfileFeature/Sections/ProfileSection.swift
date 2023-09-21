import ButtonStyles
import Colors
import God
import SwiftUI

public struct ProfileSection: View {
  let friendsCount: Int
  let votedCount: Int
  let username: String
  let displayName: String
  let schoolShortName: String?
  let grade: String?
  let editProfile: (() -> Void)?

  public init(
    friendsCount: Int,
    votedCount: Int,
    username: String,
    displayName: String,
    schoolShortName: String?,
    grade: String?,
    editProfile: (() -> Void)? = nil
  ) {
    self.friendsCount = friendsCount
    self.votedCount = votedCount
    self.username = username
    self.displayName = displayName
    self.schoolShortName = schoolShortName
    self.grade = grade
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

            Text(votedCount.description)
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
        Text(displayName)
          .bold()

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
      .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
    .background(Color.godWhite)
  }
}

#Preview {
  ProfileSection(
    friendsCount: 10,
    votedCount: 100,
    username: "tomokisun",
    displayName: "つきやま ともき",
    schoolShortName: "KHS",
    grade: "1年生"
  )
}
