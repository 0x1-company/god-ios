import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct GodModeReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case maybeLaterButtonTapped
    case continueButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .maybeLaterButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .continueButtonTapped:
        return .none
      }
    }
  }
}

public struct GodModeView: View {
  let store: StoreOf<GodModeReducer>

  public init(store: StoreOf<GodModeReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      VStack(spacing: 24) {
        VStack(spacing: 0) {
          Text("定期課金。いつでもキャンセルできます。")
          Text("お支払いはiTunesアカウントに請求され、iTunes Storeの設定でキャンセルするまで、購読は週[金額]円で自動更新されます。ロック解除をタップすると、利用規約と自動更新に同意したことになります。")
        }
        .font(.caption)
        .padding(.horizontal, 24)
        .foregroundColor(Color.gray)
        .multilineTextAlignment(.center)

        VStack(spacing: 16) {
          Image("see-who-likes-you", bundle: .module)
            .resizable()
            .scaledToFit()
            .padding(.horizontal, 60)

          GodModeFunctions()

          Text("¥960/week")

          Button {
            store.send(.continueButtonTapped)
          } label: {
            Text("Continue")
              .bold()
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .foregroundColor(Color.white)
              .background(Color.orange.gradient)
              .clipShape(Capsule())
              .padding(.horizontal, 60)
          }
          .buttonStyle(HoldDownButtonStyle())

          Button {
            store.send(.maybeLaterButtonTapped)
          } label: {
            Text("Maybe Later")
              .foregroundColor(Color.gray)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .foregroundColor(Color.white)
        .padding(.vertical, 24)
        .background(Color.black.gradient)
        .cornerRadius(32 / 2)
        .overlay(
          RoundedRectangle(cornerRadius: 32 / 2)
            .stroke(Color.orange, lineWidth: 2)
        )
        .padding(.horizontal, 8)

        Spacer()
      }
      .background(Color.godBlack)
    }
  }
}

struct GodModeViewPreviews: PreviewProvider {
  static var previews: some View {
    GodModeView(
      store: .init(
        initialState: GodModeReducer.State(),
        reducer: { GodModeReducer() }
      )
    )
  }
}
