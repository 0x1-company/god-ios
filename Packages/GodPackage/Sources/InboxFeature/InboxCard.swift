import ButtonStyles
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
        } label: {
          Label {
            Text("From a \(gender)", bundle: .module)
          } icon: {
            Group {
              if isRead {
                Image(ImageResource.unreadIcon)
                  .resizable()
              } else {
                Image(ImageResource.otherIcon)
                  .resizable()
              }
            }
            .scaledToFit()
            .frame(width: 40)
          }
        }
        .padding(.horizontal, 16)
      }
      .frame(height: 72)
      .background(Color.white)
      .cornerRadius(8)
      .compositingGroup()
      .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
    .listRowSeparator(.hidden)
    .buttonStyle(HoldDownButtonStyle())
  }
}
