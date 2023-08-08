import ButtonStyles
import SwiftUI

public struct NextButton: View {
  let isLoading: Bool
  let isDisabled: Bool
  let action: () -> Void

  public init(
    isLoading: Bool = false,
    isDisabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.isLoading = isLoading
    self.isDisabled = isDisabled
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Group {
        if isLoading {
          ProgressView()
            .progressViewStyle(.circular)
            .tint(Color.black)
        } else {
          Text("Next")
        }
      }
      .bold()
      .frame(height: 54)
      .frame(maxWidth: .infinity)
      .foregroundColor(Color.black)
      .background(Color.white)
      .clipShape(Capsule())
      .opacity(isLoading || isDisabled ? 0.5 : 1.0)
    }
    .disabled(isLoading || isDisabled)
    .buttonStyle(HoldDownButtonStyle())
  }
}

struct NextButtonPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
      NextButton(isLoading: false, isDisabled: false, action: {})
      NextButton(isLoading: true, isDisabled: false, action: {})
      NextButton(isLoading: false, isDisabled: true, action: {})
      NextButton(isLoading: true, isDisabled: true, action: {})
    }
    .padding()
    .background(Color.orange)
    .previewLayout(.sizeThatFits)
  }
}
