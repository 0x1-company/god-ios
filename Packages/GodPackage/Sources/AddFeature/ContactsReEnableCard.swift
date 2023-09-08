import Colors
import SwiftUI

public struct ContactsReEnableCard: View {
  let action: () -> Void

  public var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 16) {
        Image(systemName: "person.crop.square.fill")
          .font(.system(size: 30))
        VStack(alignment: .leading, spacing: 4) {
          Text("Contacts are disabled")
            .bold()
          Text("Tap to re-enable")
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Image(systemName: "chevron.right")
      }
      .frame(height: 70)
      .padding(.horizontal, 16)
      .foregroundColor(.white)
      .background(Color.godService)
    }
    .onTapGesture(perform: action)
  }
}
