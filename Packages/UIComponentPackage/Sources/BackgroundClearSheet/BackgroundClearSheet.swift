import SwiftUI

private struct BackgroundClearView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    Task {
      view.superview?.superview?.backgroundColor = .clear
    }
    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {}
}

public extension View {
  public func backgroundClearSheet() -> some View {
    background(BackgroundClearView())
  }
}
