import ButtonStyles
import SwiftUI

public struct InboxCard: View {
  let state: State
  let action: () -> Void

  public struct State: Equatable, Identifiable {
    public let id: String
    let gender: String
    let createdAt: Date
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        LabeledContent {
          Text(state.createdAt, style: .relative)
        } label: {
          Label {
            Text("From a \(state.gender)", bundle: .module)
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
