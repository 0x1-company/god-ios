import God
import Styleguide
import SwiftUI

public struct InboxCard: View {
  let inbox: God.InboxCardFragment
  let action: () -> Void

  var text: String {
    inbox.isRead
      ? inbox.question.text.ja
      : String(localized: "From a \(gender)", bundle: .module)
  }

  var gender: String {
    switch inbox.voteUser.gender.value {
    case .male:
      return String(localized: "boy", bundle: .module)
    case .female:
      return String(localized: "girl", bundle: .module)
    default:
      return String(localized: "someone", bundle: .module)
    }
  }

  var genderIcon: ImageResource {
    switch inbox.voteUser.gender.value {
    case .male:
      return ImageResource.boyIcon
    case .female:
      return ImageResource.girlIcon
    default:
      return ImageResource.otherIcon
    }
  }

  var genderColor: Color {
    switch inbox.voteUser.gender.value {
    case .male:
      return Color.godBlue
    default:
      return Color.godPink
    }
  }

  var createdAt: Date? {
    guard let interval = TimeInterval(inbox.createdAt)
    else { return nil }
    return Date(timeIntervalSince1970: interval / 1000.0)
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        LabeledContent {
          if let createdAt {
            Text(createdAt, style: .relative)
              .font(.footnote)
              .foregroundStyle(inbox.isRead ? Color.godTextSecondaryLight : Color.primary)
          }
        } label: {
          Label {
            Text(text)
              .multilineTextAlignment(.leading)
              .font(.system(.body, design: .rounded, weight: .bold))
              .foregroundStyle(inbox.isRead ? Color.godTextSecondaryLight : genderColor)
          } icon: {
            Image(genderIcon)
              .resizable()
              .scaledToFit()
              .frame(width: 56)
          }
        }
        .padding(.horizontal, 16)
      }
      .frame(height: 72)
      .background(inbox.isRead ? Color.godBackgroundWhite : Color.white)
      .cornerRadius(8)
      .compositingGroup()
      .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
    .listRowSeparator(.hidden)
    .buttonStyle(HoldDownButtonStyle())
  }
}
