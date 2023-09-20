import ButtonStyles
import SwiftUI

public struct FromGodTeamCard: View {
  let action: () -> Void

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        LabeledContent {
          Text(Date.now, style: .relative)
        } label: {
          Label {
            Text("From God Team", bundle: .module)
          } icon: {
            Image(ImageResource.godTeamIcon)
              .resizable()
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

#Preview {
  FromGodTeamCard(action: {})
}
