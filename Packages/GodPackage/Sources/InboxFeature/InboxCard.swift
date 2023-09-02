import ButtonStyles
import SwiftUI

public struct InboxCard: View {
  let title: String
  let action: () -> Void

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        LabeledContent {
          Text("16h")
        } label: {
          Label {
            Text(title)
          } icon: {
            Image(systemName: "flame.fill")
              .font(.largeTitle)
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
