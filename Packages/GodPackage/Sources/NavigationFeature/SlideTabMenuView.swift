import SwiftUI

struct SlideTabMenuView: View {
  let tabItems: [RootNavigationLogic.Tab]
  @Binding var selection: RootNavigationLogic.Tab

  var before: RootNavigationLogic.Tab? {
    Array(tabItems.enumerated())
      .first(where: { $0.element == selection })
      .map { $0.offset == tabItems.startIndex ? nil : tabItems[$0.offset - 1] }
      ?? nil
  }

  var after: RootNavigationLogic.Tab? {
    Array(tabItems.enumerated())
      .first(where: { $0.element == selection })
      .map { $0.offset + 1 == tabItems.endIndex ? nil : tabItems[$0.offset + 1] }
      ?? nil
  }

  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        Button {
          withAnimation(.default) {
            selection = before ?? selection
          }
        } label: {
          Text(before?.rawValue ?? "", bundle: .module)
        }
        .frame(width: geometry.size.width / 3, alignment: .leading)
        .buttonStyle(TabButtonStyle(isSelected: false))

        Button(action: {}) {
          Text(selection.rawValue, bundle: .module)
        }
        .frame(width: geometry.size.width / 3)
        .buttonStyle(TabButtonStyle(isSelected: true))

        Button {
          withAnimation(.default) {
            selection = after ?? selection
          }
        } label: {
          Text(after?.rawValue ?? "", bundle: .module)
        }
        .frame(width: geometry.size.width / 3, alignment: .trailing)
        .buttonStyle(TabButtonStyle(isSelected: false))
      }
      .frame(height: 52)
      .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 16)
  }

  struct TabButtonStyle: ButtonStyle {
    let isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .foregroundStyle(isSelected ? Color.black : Color.secondary)
        .font(.system(.callout, design: .rounded, weight: .bold))
        .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        .animation(.default, value: configuration.isPressed)
    }
  }
}
