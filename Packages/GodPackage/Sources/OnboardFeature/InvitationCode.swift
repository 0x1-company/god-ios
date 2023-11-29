import AnalyticsClient
import ComposableArchitecture
import SwiftUI

@Reducer
public struct InvitationCodeLogic {
  public init() {}

  public struct State: Equatable {
    @BindingState var invitationCode = ""
    var isDisabled = true
    public init() {}
  }

  public enum Action: BindableAction {
    case onTask
    case onAppear
    case nextButtonTapped
    case skipButtonTapped
    case binding(BindingAction<State>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen(String?)
    }
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "InvitationCode", of: self)
        return .none

      case .nextButtonTapped:
        let code = state.invitationCode
        return .send(.delegate(.nextScreen(code)))

      case .skipButtonTapped:
        return .send(.delegate(.nextScreen(nil)))

      case .binding(\.$invitationCode):
        state.isDisabled = state.invitationCode.count != 6
        return .none

      default:
        return .none
      }
    }
  }
}

public struct InvitationCodeView: View {
  let store: StoreOf<InvitationCodeLogic>

  public init(store: StoreOf<InvitationCodeLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 12) {
        Spacer()
        Text("Do you have invitation code?", bundle: .module)
          .font(.system(.title3, design: .rounded, weight: .bold))

        Text("If you do not have it, you can skip it.", bundle: .module)
          .font(.system(.body, design: .rounded))

        TextField(text: viewStore.$invitationCode) {
          Text("ABCDEF", bundle: .module)
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .font(.system(.title, design: .rounded))

        Spacer()

        NextButton(isDisabled: viewStore.isDisabled) {
          store.send(.nextButtonTapped)
        }

        Button {
          store.send(.skipButtonTapped)
        } label: {
          Text("Skip", bundle: .module)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .font(.system(.body, design: .rounded))
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .foregroundStyle(Color.white)
      .background(Color.godService)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  NavigationStack {
    InvitationCodeView(
      store: .init(
        initialState: InvitationCodeLogic.State(),
        reducer: { InvitationCodeLogic() }
      )
    )
  }
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
