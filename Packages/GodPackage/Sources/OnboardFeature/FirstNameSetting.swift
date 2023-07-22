import ComposableArchitecture
import SwiftUI

public struct FirstNameSettingReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    @BindingState var firstName = ""
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { _, action in
      switch action {
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
      .toolbar {
        Button {
          
        } label: {
          Image(systemName: "info.circle.fill")
            .foregroundColor(.white)
        }
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
          reducer: FirstNameSettingReducer()
        )
      )
    }
  }
}
