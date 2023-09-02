import SwiftUI

public struct GodModeFunctions: View {
  public var body: some View {
    TabView {
      VStack {
        Image("reveal-2-names-per-week-boy", bundle: .module)
          .resizable()
          .scaledToFit()

        Text("Reveal 2 Names Per Week")
      }
      .padding(.horizontal, 100)

      VStack {
        Image("reveal-2-names-per-week-boy", bundle: .module)
          .resizable()
          .scaledToFit()

        Text("Reveal 2 Names Per Week")
      }
      .padding(.horizontal, 100)

      VStack {
        Image("double-coin", bundle: .module)
          .resizable()
          .scaledToFit()

        Text("Get Double Coins on Polls")
      }
      .padding(.horizontal, 100)

      VStack {
        Image("secret-crush-alerts-boy", bundle: .module)
          .resizable()
          .scaledToFit()

        Text("Secret Crush Alerts")
      }
      .padding(.horizontal, 100)
    }
    .tabViewStyle(.page)
    .multilineTextAlignment(.center)
  }
}

struct GodModeFunctionsPreviews: PreviewProvider {
  static var previews: some View {
    GodModeFunctions()
  }
}
