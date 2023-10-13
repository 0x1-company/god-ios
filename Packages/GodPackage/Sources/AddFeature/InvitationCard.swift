import ComposableArchitecture
import NameImage
import Styleguide
import SwiftUI

public struct InvitationCardView: View {
  let familyName: String
  let givenName: String
  let imageData: Data?
  let action: () -> Void

  var displayName: String {
    "\(familyName) \(givenName)"
  }

  public var body: some View {
    HStack(spacing: 16) {
      if let imageData, let image = UIImage(data: imageData) {
        Image(uiImage: image)
          .resizable()
          .frame(width: 42, height: 42)
          .clipShape(Circle())
      } else {
        NameImage(name: givenName, size: 42)
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(verbatim: displayName)
          .bold()
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Button(action: action) {
        Text("INVITE", bundle: .module)
          .bold()
          .frame(height: 34)
          .foregroundColor(.godService)
          .padding(.horizontal, 12)
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
