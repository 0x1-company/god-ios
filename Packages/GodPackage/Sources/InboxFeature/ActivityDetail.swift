import AnimationDisableTransaction
import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct ActivityDetailReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeWhoSentItButtonTapped
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .seeWhoSentItButtonTapped:
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct ActivityDetailView: View {
  let store: StoreOf<ActivityDetailReducer>

  public init(store: StoreOf<ActivityDetailReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        VStack(spacing: 50) {
          Spacer()

          VStack(spacing: 20) {
            Image("other", bundle: .module)
              .resizable()
              .frame(width: 80, height: 80)

            Text("From someone\nin 11th grade")
          }

          VStack(spacing: 20) {
            Text("Double texts with no shame")
              .bold()

            Text("godapp.jp")
              .bold()
          }
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.godPurple)
        .foregroundColor(.godWhite)
        .multilineTextAlignment(.center)
        .onTapGesture {
          viewStore.send(.closeButtonTapped, transaction: .animationDisable)
        }

        Button {
          viewStore.send(.seeWhoSentItButtonTapped)
        } label: {
          Label("See who sent it", systemImage: "lock.fill")
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .bold()
            .foregroundColor(.white)
            .background(Color.godGray)
            .clipShape(Capsule())
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .background(.black)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ActivityDetailViewPreviews: PreviewProvider {
  static var previews: some View {
    ActivityDetailView(
      store: .init(
        initialState: ActivityDetailReducer.State(),
        reducer: { ActivityDetailReducer() }
      )
    )
  }
}
