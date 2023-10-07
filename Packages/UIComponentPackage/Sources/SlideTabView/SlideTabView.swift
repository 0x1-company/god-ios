import SwiftUI

public struct SlideTabView<SelectionValue, Content>: View where SelectionValue : Hashable, Content: View {
  @Binding var selection: SelectionValue
  @ViewBuilder var content: () -> Content
  
  public init(selection: Binding<SelectionValue>, @ViewBuilder content: @escaping () -> Content) {
    self._selection = selection
    self.content = content
  }
  
  public var body: some View {
    TabView(selection: $selection) {
      content()
    }
    .ignoresSafeArea()
    .tabViewStyle(PageTabViewStyle())
  }
}
