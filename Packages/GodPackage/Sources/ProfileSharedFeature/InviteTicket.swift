import Styleguide
import SwiftUI

public struct InviteTicket: View {
  let code: String
  
  public init(
    code: String
  ) {
    self.code = code
  }

  public var body: some View {
    Image(ImageResource.inviteTicket)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .overlay(alignment: .center) {
        Text(code)
          .foregroundStyle(Color(0xFFFF_CC00))
          .font(.system(.largeTitle, design: .rounded, weight: .bold))
          .offset(x: -35, y: 8)
      }
  }
}

#Preview {
  InviteTicket(code: "ABCDEF")
}
