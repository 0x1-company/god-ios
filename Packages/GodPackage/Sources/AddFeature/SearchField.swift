import SwiftUI

public struct SearchField: View {
  @Binding var text: String

  public var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.secondary)
      TextField("Search...", text: $text)
        .keyboardType(.webSearch)
        .textContentType(.username)
    }
    .padding(.horizontal, 16)
    .frame(height: 56)
  }
}
