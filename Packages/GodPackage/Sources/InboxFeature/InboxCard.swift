import ButtonStyles
import Colors
import SwiftUI

public struct InboxCard: View {
  let gender: String
  let createdAt: Date
  let isRead: Bool
  let action: () -> Void

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        LabeledContent {
          Text(createdAt, style: .relative)
            .font(.footnote)
        } label: {
          Label {
            Text("From a \(gender)", bundle: .module)
          } icon: {
            Image(isRead ? ImageResource.unreadIcon : ImageResource.otherIcon)
              .resizable()
              .scaledToFit()
              .frame(width: 56)
          }
        }
        .padding(.horizontal, 16)
      }
      .frame(height: 72)
      .foregroundStyle(isRead ? Color.godTextSecondaryLight : Color.primary)
      .background(isRead ? Color.godBackgroundWhite : Color.white)
      .cornerRadius(8)
      .compositingGroup()
      .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
    .listRowSeparator(.hidden)
    .buttonStyle(HoldDownButtonStyle())
  }
}

#Preview {
  InboxCard(
    gender: "男子",
    createdAt: .now,
    isRead: true,
    action: {}
  )
}

#Preview {
  InboxCard(
    gender: "女子",
    createdAt: .now,
    isRead: false,
    action: {}
  )
}
