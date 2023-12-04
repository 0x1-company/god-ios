import AnalyticsClient
import ComposableArchitecture
import RoundedCorner
import Styleguide
import SwiftUI

@Reducer
public struct PrefectureLogic {
  public init() {}

  public struct State: Equatable {
    var prefectures: [String] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case prefectureButtonTapped(String)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case nextScreen(prefecture: String)
    }
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "Prefecture", of: self)
        return .none

      case let .prefectureButtonTapped(prefecture):
        return .send(.delegate(.nextScreen(prefecture: prefecture)))
        
      default:
        return .none
      }
    }
  }
}

public struct PrefectureView: View {
  let store: StoreOf<PrefectureLogic>

  public init(store: StoreOf<PrefectureLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        Color.godService

        List {
          ForEach(viewStore.prefectures, id: \.self) { prefecture in
            Button {
              store.send(.prefectureButtonTapped(prefecture))
            } label: {
              Text(prefecture)
                .font(.system(.body, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
        .listStyle(.plain)
        .foregroundStyle(.primary)
        .background(Color.white)
        .multilineTextAlignment(.center)
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .navigationTitle(Text("Pick your prefecture", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }
}

#Preview {
  NavigationStack {
    PrefectureView(
      store: .init(
        initialState: PrefectureLogic.State(),
        reducer: { PrefectureLogic() }
      )
    )
  }
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
