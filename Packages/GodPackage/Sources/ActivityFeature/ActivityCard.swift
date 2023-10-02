import God
import ProfilePicture
import SwiftUI

public struct ActivityCard: View {
  let activity: God.ActivitiesQuery.Data.ListActivities.Edge
  let action: (God.ActivitiesQuery.Data.ListActivities.Edge) -> Void

  var gender: String {
    switch activity.node.voteUser.gender.value {
    case .male:
      return String(localized: "boy", bundle: .module)
    case .female:
      return String(localized: "girl", bundle: .module)
    default:
      return String(localized: "non-binary", bundle: .module)
    }
  }

  var genderIcon: ImageResource {
    switch activity.node.voteUser.gender.value {
    case .male:
      return ImageResource.boy
    case .female:
      return ImageResource.girl
    default:
      return ImageResource.other
    }
  }

  var createdAt: Date? {
    guard let interval = TimeInterval(activity.node.createdAt)
    else { return nil }
    return Date(timeIntervalSince1970: interval / 1000.0)
  }

  public var body: some View {
    Button {
      action(activity)
    } label: {
      HStack(alignment: .top, spacing: 16) {
        ProfilePicture(
          url: URL(string: activity.node.user.imageURL),
          familyName: activity.node.user.lastName,
          givenName: activity.node.user.firstName,
          size: 42
        )

        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 4) {
            Text(activity.node.user.displayName.ja)
              .bold()
              .font(.callout)
            Text("received", bundle: .module)
              .font(.footnote)
          }

          Text(activity.node.question.text.ja)

          HStack(spacing: 8) {
            Image(genderIcon)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .clipped()
              .frame(width: 14, height: 14)

            Group {
              if let grade = activity.node.voteUser.grade {
                Text("From a \(gender) in \(grade)", bundle: .module)
              } else {
                Text("From a \(gender)", bundle: .module)
              }
            }
            .foregroundStyle(.secondary)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

//        if let createdAt {
//          Text(createdAt, style: .relative)
//            .foregroundColor(.secondary)
//        }
      }
      .padding(.vertical, 8)
    }
  }
}
