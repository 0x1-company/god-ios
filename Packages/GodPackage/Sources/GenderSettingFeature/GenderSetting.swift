import Colors
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
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextProfilePhotoSetting
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .infoButtonTapped:
        state.help = .init()
        return .none

      case .boyButtonTapped:
        return .run { send in
          await send(.delegate(.nextProfilePhotoSetting))
        }
      case .girlButtonTapped:
        return .run { send in
          await send(.delegate(.nextProfilePhotoSetting))
        }
      case .nonBinaryButtonTapped:
        return .run { send in
          await send(.delegate(.nextProfilePhotoSetting))
        }
      case .help:
        return .none

      case .delegate:
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
      ZStack {
        Color.god.service
          .ignoresSafeArea()

        VStack(spacing: 24) {
          Text("What's your gender?")
            .bold()
            .foregroundColor(Color.white)

          HStack(spacing: 24) {
            GenderChoiceView("Boy") {
              viewStore.send(.boyButtonTapped)
            }
            GenderChoiceView("Girl") {
              viewStore.send(.girlButtonTapped)
            }
          }
          HStack(spacing: 24) {
            GenderChoiceView("Non-binary") {
              viewStore.send(.nonBinaryButtonTapped)
            }
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
          .presentationDragIndicator(.visible)
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
