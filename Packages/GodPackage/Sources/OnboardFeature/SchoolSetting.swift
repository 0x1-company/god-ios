import Colors
import ComposableArchitecture
import RoundedCorner
import SwiftUI

public struct SchoolSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct SchoolSettingView: View {
  let store: StoreOf<SchoolSettingReducer>

  public init(store: StoreOf<SchoolSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      ZStack(alignment: .center) {
        Color.god.service

        VStack(spacing: 0) {
          Spacer()
          Text("hoge")
            .frame(maxWidth: .infinity)
          Spacer()
        }
        .foregroundColor(.primary)
        .background(Color.white)
        .multilineTextAlignment(.center)
        .cornerRadius(12, corners: [.topLeft, .topRight])
      }
      .navigationTitle("Pick your school")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.god.service, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }
}

struct SchoolSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    SchoolSettingView(
      store: .init(
        initialState: SchoolSettingReducer.State(),
        reducer: { SchoolSettingReducer() }
      )
    )
  }
}
