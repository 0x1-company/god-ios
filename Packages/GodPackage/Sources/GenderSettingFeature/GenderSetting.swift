import ComposableArchitecture
import SwiftUI

public struct GenderSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var help: GenderHelpReducer.State?
    public init() {}
  }

  public enum Action: Equatable {
    case infoButtonTapped
    case boyButtonTapped
    case girlButtonTapped
    case nonBinaryButtonTapped
    case help(PresentationAction<GenderHelpReducer.Action>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .infoButtonTapped:
        state.help = .init()
        return .none

      case .boyButtonTapped:
        return .none

      case .girlButtonTapped:
        return .none

      case .nonBinaryButtonTapped:
        return .none

      case .help:
        return .none
      }
    }
    .ifLet(\.$help, action: /Action.help) {
      GenderHelpReducer()
    }
  }
}

public struct GenderSettingView: View {
  let store: StoreOf<GenderSettingReducer>

  public init(store: StoreOf<GenderSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 24) {
        Text("What's your gender?")

        HStack(spacing: 24) {
          Button {
            viewStore.send(.boyButtonTapped)
          } label: {
            Color.red
              .frame(width: 120, height: 120)
              .cornerRadius(12)
          }
          Button {
            viewStore.send(.girlButtonTapped)
          } label: {
            Color.blue
              .frame(width: 120, height: 120)
              .cornerRadius(12)
          }
        }
        HStack(spacing: 24) {
          Button {
            viewStore.send(.nonBinaryButtonTapped)
          } label: {
            Color.orange
              .frame(width: 120, height: 120)
              .cornerRadius(12)
          }
        }
      }
      .toolbar {
        Button {
          viewStore.send(.infoButtonTapped)
        } label: {
          Image(systemName: "info.circle.fill")
            .foregroundColor(.white)
        }
      }
      .sheet(
        store: store.scope(
          state: \.$help,
          action: GenderSettingReducer.Action.help
        )
      ) { store in
        GenderHelpView(store: store)
          .presentationDetents([.fraction(0.4)])
      }
    }
  }
}

struct GenderSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      GenderSettingView(
        store: .init(
          initialState: GenderSettingReducer.State(),
          reducer: { GenderSettingReducer() }
        )
      )
    }
  }
}
