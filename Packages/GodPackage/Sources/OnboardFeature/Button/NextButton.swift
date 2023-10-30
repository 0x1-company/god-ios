import Styleguide
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
          Text("Next", bundle: .module)
        }
      }
      .font(.system(.body, design: .rounded, weight: .bold))
      .frame(height: 54)
      .frame(maxWidth: .infinity)
      .foregroundStyle(Color.black)
      .background(Color.white)
      .clipShape(Capsule())
      .opacity(isLoading || isDisabled ? 0.5 : 1.0)
    }
    .disabled(isLoading || isDisabled)
    .buttonStyle(HoldDownButtonStyle())
  }
}
