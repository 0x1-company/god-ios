import SwiftUI

public struct SearchField: View {
  @Binding var text: String

  public init(text: Binding<String>) {
    _text = text
  }

  public var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.secondary)
      TextField(text: $text) {
        Text("Search...", bundle: .module)
      }
      .keyboardType(.webSearch)
      .textContentType(.username)
    }
    .padding(.horizontal, 16)
    .frame(height: 56)
  }
}
