import SwiftUI

public struct GodModeFunctions: View {
  public var body: some View {
    TabView {
      VStack(spacing: 12) {
        Image(ImageResource.reveal2NamesPerWeekBoy)
          .resizable()
          .scaledToFit()
          .frame(height: 120)

        Text("Reveal 2 Names Per Week", bundle: .module)
      }
      .padding(.horizontal, 100)

      VStack(spacing: 12) {
        Image(ImageResource.getUnlimitedHints)
          .resizable()
          .scaledToFit()
          .frame(height: 120)

        Text("Get Unlimited Hints", bundle: .module)
      }
      .padding(.horizontal, 100)

      VStack(spacing: 12) {
        Image(ImageResource.doubleCoin)
          .resizable()
          .scaledToFit()
          .frame(height: 120)

        Text("Get Double Coins on Polls", bundle: .module)
      }
      .padding(.horizontal, 100)

      VStack(spacing: 12) {
        Image(ImageResource.secretCrushAlertsBoy)
          .resizable()
          .scaledToFit()
          .frame(height: 120)

        Text("Secret Crush Alerts", bundle: .module)
      }
      .padding(.horizontal, 100)
    }
    .bold()
    .frame(height: 260)
    .tabViewStyle(.page)
    .multilineTextAlignment(.center)
  }
}

#Preview {
  GodModeFunctions()
}
