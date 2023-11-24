import ComposableArchitecture
import Styleguide
import SwiftUI

@Reducer
public struct NotInSchoolLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {
    case onTapGesture
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case editProfile
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTapGesture:
        return .send(.delegate(.editProfile))

      case .delegate:
        return .none
      }
    }
  }
}

public struct NotInSchoolView: View {
  let store: StoreOf<NotInSchoolLogic>

  public init(store: StoreOf<NotInSchoolLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        HStack(spacing: 16) {
          Image(ImageResource.school)
            .resizable()
            .frame(width: 30, height: 30)

          VStack(alignment: .leading, spacing: 4) {
            Text("You are not in high school", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))

            Text("Tap to select a high school", bundle: .module)
              .font(.system(.body, design: .rounded))
              .foregroundStyle(Color.white.opacity(0.6))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          Image(systemName: "chevron.right")
        }
        .frame(height: 70)
        .padding(.horizontal, 16)
        .foregroundStyle(.white)
        .background(Color.godService)
      }
      .onTapGesture {
        store.send(.onTapGesture)
      }
    }
  }
}

#Preview {
  NotInSchoolView(
    store: .init(
      initialState: NotInSchoolLogic.State(),
      reducer: { NotInSchoolLogic() }
    )
  )
}
