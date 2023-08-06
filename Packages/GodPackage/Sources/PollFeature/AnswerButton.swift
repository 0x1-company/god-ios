import ColorHex
import SwiftUI

private struct AnswerButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
  }
}

public struct AnswerButton: View {
  let title: String
  let progress: Double
  let action: () -> Void

  public init(
    _ title: String,
    progress: Double,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.progress = progress
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Text(verbatim: title)
        .bold()
        .lineLimit(2)
        .multilineTextAlignment(.leading)
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .foregroundColor(.black)
        .background(
          GeometryReader { proxy in
            HStack(spacing: 0) {
              Color(0xFF94_DE98)
                .frame(width: proxy.size.width * progress)
              Color.white
            }
            .animation(.easeIn(duration: 0.3), value: progress)
          }
        )
        .cornerRadius(8)
    }
    .buttonStyle(AnswerButtonStyle())
    .shadow(color: .black.opacity(0.2), radius: 25)
  }
}

struct AnswerButtonPreviews: PreviewProvider {
  static var previews: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(spacing: 16), count: 2),
      spacing: 16,
      content: {
        AnswerButton("Ariana Duclos", progress: 0.1, action: {})
        AnswerButton("Allie Yarbrough", progress: 0.3, action: {})
        AnswerButton("Abby Arambula", progress: 0.5, action: {})
        AnswerButton("Ava Griego", progress: 0.9, action: {})
      }
    )
    .padding()
    .background(Color(0xFF58_C150))
    .previewLayout(.sizeThatFits)
  }
}
