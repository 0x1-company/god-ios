import SwiftUI

public struct GodModeFunctions: View {
  public var body: some View {
    TabView {
      VStack {
        Image(.reveal2NamesPerWeekBoy)
          .resizable()
          .scaledToFit()

        Text("Reveal 2 Names Per Week", bundle: .module)
      }
      .padding(.horizontal, 100)

      VStack {
        Image(.reveal2NamesPerWeekBoy)
          .resizable()
          .scaledToFit()

        Text("Reveal 2 Names Per Week", bundle: .module)
      }
      .padding(.horizontal, 100)

      VStack {
        Image(.doubleCoin)
          .resizable()
          .scaledToFit()

        Text("Get Double Coins on Polls", bundle: .module)
      }
      .padding(.horizontal, 100)

      VStack {
        Image(.secretCrushAlertsBoy)
          .resizable()
          .scaledToFit()

        Text("Secret Crush Alerts", bundle: .module)
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
