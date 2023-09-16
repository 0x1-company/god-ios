import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct InvitationCardView: View {
  let familyName: String
  let givenName: String
  let action: () -> Void
  
  var displayName: String {
    return "\(familyName) \(givenName)"
  }
  
  public var body: some View {
    HStack(spacing: 16) {
      Color.red
        .frame(width: 42, height: 42)
        .clipShape(Circle())

      VStack(alignment: .leading, spacing: 4) {
        Text(verbatim: displayName)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      
      Button(action: action) {
        Text("INVITE", bundle: .module)
          .bold()
          .frame(width: 84, height: 34)
          .foregroundColor(.godService)
          .overlay(
            RoundedRectangle(cornerRadius: 34 / 2)
              .stroke(Color.godService, lineWidth: 1)
          )
      }
      .buttonStyle(HoldDownButtonStyle())
    }
    .frame(height: 76)
    .padding(.horizontal, 16)
  }
}
