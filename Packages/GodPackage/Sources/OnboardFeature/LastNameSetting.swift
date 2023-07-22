import ComposableArchitecture
import SwiftUI

public struct LastNameSettingReducer: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    @BindingState var lastName = ""
    @PresentationState var alert: AlertState<Action.Alert>?
    public init() {}
  }
  
  public enum Action: Equatable, BindableAction {
    case infoButtonTapped
    case alert(PresentationAction<Alert>)
    case binding(BindingAction<State>)
    
    public enum Alert: Equatable {
      case confirmContinueAnyway
      case confirmOkay
    }
  }
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .infoButtonTapped:
        state.alert = AlertState {
          TextState("Double check your name")
        } actions: {
          ButtonState(action: .confirmContinueAnyway) {
            TextState("Continue Anyway")
          }
          ButtonState(action: .confirmOkay) {
            TextState("OK")
          }
        } message: {
          TextState("Your friends may see you as the name in their contacts")
        }
        return .none

      case .alert(.presented(.confirmContinueAnyway)):
        return .none

      case .alert(.presented(.confirmOkay)):
        return .none

      case .alert:
        return .none
        
      case .binding:
        return .none
      }
    }
  }
}

public struct LastNameSettingView: View {
  let store: StoreOf<LastNameSettingReducer>
  
  public init(store: StoreOf<LastNameSettingReducer>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("What's your last name?")
          .bold()
          .foregroundColor(.white)
        TextField("Last Name", text: viewStore.binding(\.$lastName))
          .font(.title)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
          .textContentType(.familyName)
        Spacer()
        Button {
        } label: {
          Text("Next")
            .bold()
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
            .background(Color.white)
            .clipShape(Capsule())
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color(0xFFED6C43))
      .alert(
        store: store.scope(
          state: \.$alert,
          action: { .alert($0) }
        )
      )
      .toolbar {
        Button {
          viewStore.send(.infoButtonTapped)
        } label: {
          Image(systemName: "info.circle.fill")
            .foregroundColor(.white)
        }
      }
    }
  }
}

struct LastNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LastNameSettingView(
        store: .init(
          initialState: LastNameSettingReducer.State(),
          reducer: LastNameSettingReducer()
        )
      )
    }
  }
}
