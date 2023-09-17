import SwiftUI

public struct FriendHeader: View {
  var title: LocalizedStringKey

  public var body: some View {
    VStack(spacing: 0) {
      Divider()

      Text(title, bundle: .module)
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 34)
        .padding(.horizontal, 16)
        .foregroundColor(.secondary)
        .background(Color(uiColor: .quaternarySystemFill))

      Divider()
    }
  }
}
