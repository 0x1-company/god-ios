import Colors
import ComposableArchitecture
import SwiftUI

public struct FromGodTeamLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct FromGodTeamView: View {
  let store: StoreOf<FromGodTeamLogic>

  public init(store: StoreOf<FromGodTeamLogic>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 16) {
        Image(ImageResource.god)
          .resizable()
          .scaledToFit()
          .frame(width: 94)

        Text("From the God team", bundle: .module)
      }

      Spacer()

      HStack {
        Image(.girl)
          .resizable()
          .frame(width: 30, height: 30)
        Text("A girl in 9th grade\npicked you", bundle: .module)
      }
      .bold()
      .frame(height: 48)
      .padding(.horizontal, 12)
      .background(Color.godWhite)
      .foregroundColor(Color.godTextPrimary)
      .multilineTextAlignment(.leading)
      .font(.caption)
      .cornerRadius(8)

      Text("This is your inbox", bundle: .module)
        .font(.title3)
        .bold()

      Text("When people pick you\nyou will get a message here.", bundle: .module)

      Spacer()

      Text("Tap anywhere to close", bundle: .module)
    }
    .padding(.vertical, 40)
    .foregroundColor(Color.godWhite)
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .background(Color.godService)
    .onTapGesture {
      store.send(.closeButtonTapped)
    }
  }
}

struct FromGodTeamViewPreviews: PreviewProvider {
  static var previews: some View {
    FromGodTeamView(
      store: .init(
        initialState: FromGodTeamLogic.State(),
        reducer: { FromGodTeamLogic() }
      )
    )
  }
}
