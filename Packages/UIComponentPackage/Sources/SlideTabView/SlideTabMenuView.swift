import SwiftUI

public struct SlideTabMenuView: View {
  let tabItems: [String]
  @Binding var selection: String
  let action: (String) -> Void
  
  var before: String {
    return Array(tabItems.enumerated())
      .first(where: { $0.element == selection })
      .map { $0.offset == tabItems.startIndex ? "" : tabItems[$0.offset - 1] }
      ?? ""
  }
  
  var after: String {
    return Array(tabItems.enumerated())
      .first(where: { $0.element == selection })
      .map { $0.offset + 1 == tabItems.endIndex ? "" : tabItems[$0.offset + 1] }
      ?? ""
  }

  public var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        Button(before) {
          action(before)
        }
        .frame(width: geometry.size.width / 3, alignment: .leading)
        .buttonStyle(TabButtonStyle(isSelected: false))
        
        Button(selection) {
          action(selection)
        }
        .frame(width: geometry.size.width / 3)
        .buttonStyle(TabButtonStyle(isSelected: true))
        
        Button(after) {
          action(after)
        }
        .frame(width: geometry.size.width / 3, alignment: .trailing)
        .buttonStyle(TabButtonStyle(isSelected: false))
      }
      .frame(height: 52)
      .frame(maxWidth: .infinity)
    }
  }
  
  struct TabButtonStyle: ButtonStyle {
    let isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .foregroundStyle(isSelected ? Color.black : Color.secondary)
        .font(.system(.headline, design: .rounded, weight: .bold))
        .padding(.horizontal, 16)
    }
  }
}

#Preview {
  SlideTabMenuView(
    tabItems: ["Activity", "Inbox", "God", "Profile", "About"],
    selection: .constant("God"),
    action: { _ in }
  )
}
