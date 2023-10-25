import CoreHaptics
import Styleguide
import SwiftUI

public struct AnswerButton: View {
  let title: String
  let progress: Double
  let color: Color
  let action: () -> Void

  public init(
    _ title: String,
    progress: Double,
    color: Color,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.progress = progress
    self.color = color
    self.action = action
  }

  public var body: some View {
    Button {
      action()
    } label: {
      Text(verbatim: title)
        .font(.system(.body, design: .rounded, weight: .bold))
        .lineLimit(2)
        .multilineTextAlignment(.center)
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .foregroundStyle(.black)
        .padding(.horizontal, 8)
        .background(
          GeometryReader { proxy in
            HStack(spacing: 0) {
              color
                .opacity(0.4)
                .frame(width: proxy.size.width * progress)
              Color.white
            }
            .background(Color.white)
            .animation(.easeIn(duration: 0.2), value: progress)
          }
        )
        .cornerRadius(8)
    }
    .buttonStyle(HoldDownButtonStyle())
    .shadow(color: .black.opacity(0.2), radius: 25)
  }
}
