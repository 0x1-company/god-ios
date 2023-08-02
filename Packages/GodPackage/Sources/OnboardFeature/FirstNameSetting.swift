import ComposableArchitecture
import SwiftUI

public struct FirstNameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameReducer.State()
    @BindingState var firstName = ""
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case doubleCheckName(DoubleCheckNameReducer.Action)
    case binding(BindingAction<State>)
  }

  public var body: some Reducer<State, Action> {
    BindingReducer() }
    Scope(state: \.doubleCheckName, action: /Action.doubleCheckName) {
      DoubleCheckNameReducer()
    }
    Reduce { _, action in
      switch action {
      case .doubleCheckName:
        return .none

      case .binding:
        return .none
      }
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
        TextField("First Name", text: viewStore.binding(\.$firstName))
          .font(.title)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
          .textContentType(.givenName)
        Spacer()
        Button {} label: {
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
      .background(Color(0xFFED_6C43))
      .toolbar {
        DoubleCheckNameView(
          store: store.scope(
            state: \.doubleCheckName,
            action: FirstNameSettingReducer.Action.doubleCheckName
          )
        )
      }
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
