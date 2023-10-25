import AnalyticsClient
import ComposableArchitecture
import ProfileImage
import Styleguide
import SwiftUI

public struct FullNameLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let fulName: String

    public init(
      fulName: String
    ) {
      self.fulName = fulName
    }
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "FullName", of: self)
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct FullNameView: View {
  let store: StoreOf<FullNameLogic>

  public init(store: StoreOf<FullNameLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture {
            store.send(.closeButtonTapped)
          }

        VStack(spacing: 24) {
          Spacer()

          Text(verbatim: viewStore.fulName)
            .font(.system(.title2, design: .rounded, weight: .bold))

          Button {
            viewStore.send(.closeButtonTapped)
          } label: {
            Text("Close", bundle: .module)
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .foregroundStyle(.white)
              .background(Color.godService)
              .clipShape(Capsule())
              .font(.system(.body, design: .rounded, weight: .bold))
          }
          .padding(.horizontal, 16)
          .buttonStyle(HoldDownButtonStyle())
        }
        .frame(height: 150)
        .background(Color.white)
//        .overlay(alignment: .top) {
//          Color.red
//            .frame(width: 66, height: 66)
//            .clipShape(Circle())
//          .overlay {
//            RoundedRectangle(cornerRadius: 66 / 2)
//              .stroke(Color.white, lineWidth: 8)
//          }
//          .offset(y: -33)
//        }
      }
      .task { await viewStore.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  Color.black
    .ignoresSafeArea()
    .fullScreenCover(isPresented: .constant(true)) {
      Color.blue
        .ignoresSafeArea()
        .fullScreenCover(isPresented: .constant(true)) {
          FullNameView(
            store: .init(
              initialState: FullNameLogic.State(
                fulName: "Tomoki Tsukiyama"
              ),
              reducer: { FullNameLogic() }
            )
          )
          .presentationBackground(Material.ultraThinMaterial)
        }
    }
}
