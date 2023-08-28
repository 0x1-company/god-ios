import Colors
import ComposableArchitecture
import ContactsClient
import God
import GodClient
import StringHelpers
import SwiftUI

public struct FirstNameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameReducer.State()
    @PresentationState var alert: AlertState<Action.Alert>?
    var firstName = ""
    public init() {}
  }

  public enum Action: Equatable {
    case firstNameChanged(String)
    case nextButtonTapped
    case updateProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    case doubleCheckName(DoubleCheckNameReducer.Action)

    public enum Delegate: Equatable {
      case nextScreen
    }

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.contacts) var contactsClient

  public var body: some Reducer<State, Action> {
    Scope(state: \.doubleCheckName, action: /Action.doubleCheckName) {
      DoubleCheckNameReducer()
    }
    Reduce { state, action in
      switch action {
      case let .firstNameChanged(firstName):
        state.firstName = firstName
        return .none
        
      case .nextButtonTapped:
        let firstName = state.firstName
        guard
          !firstName.isEmpty,
          validateHiragana(for: firstName)
        else {
          state.alert = .hiraganaValidateError()
          return .none
        }
        let input = God.UpdateUserProfileInput(
          firstName: .init(stringLiteral: firstName)
        )
        return .run { send in
          async let next: Void = send(.delegate(.nextScreen))
          async let update: Void = send(
            .updateProfileResponse(
              TaskResult {
                try await godClient.updateUserProfile(input)
              }
            )
          )
          _ = await (next, update)
        }
      case .updateProfileResponse(.success):
        return .none
      case .updateProfileResponse(.failure):
        return .none
      case .alert:
        return .none
      case .delegate:
        return .none
      case .doubleCheckName:
        return .none
      }
    }
  }
}

extension AlertState where Action == FirstNameSettingReducer.Action.Alert {
  static func hiraganaValidateError() -> Self {
    Self {
      TextState("title")
    } actions: {
      ButtonState(action: .confirmOkay) {
        TextState("OK")
      }
    } message: {
      TextState("ひらがなのみ設定できます")
    }
  }
}

public struct FirstNameSettingView: View {
  let store: StoreOf<FirstNameSettingReducer>

  public init(store: StoreOf<FirstNameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("What's your first name?")
          .bold()
          .foregroundColor(.white)
        TextField(
          "First Name",
          text: viewStore.binding(
            get: \.firstName,
            send: FirstNameSettingReducer.Action.firstNameChanged
          )
        )
        .font(.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        Spacer()
        NextButton {
          viewStore.send(.nextButtonTapped)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color.godService)
      .navigationBarBackButtonHidden()
      .toolbar {
        DoubleCheckNameView(
          store: store.scope(
            state: \.doubleCheckName,
            action: FirstNameSettingReducer.Action.doubleCheckName
          )
        )
      }
      .alert(store: store.scope(state: \.$alert, action: FirstNameSettingReducer.Action.alert))
    }
  }
}

struct FirstNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      FirstNameSettingView(
        store: .init(
          initialState: FirstNameSettingReducer.State(),
          reducer: { FirstNameSettingReducer() }
        )
      )
    }
  }
}
