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
    case infoButtonTapped
    case schoolButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextPhoneNumber
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      case .infoButtonTapped:
        return .none
      case .schoolButtonTapped:
        return .run { send in
          await send(.delegate(.nextPhoneNumber))
        }
      case .delegate:
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        Color.god.service

        List(0 ..< 100, id: \.self) { _ in
          Button {
            viewStore.send(.schoolButtonTapped)
          } label: {
            HStack(alignment: .center, spacing: 16) {
              Color.red
                .frame(width: 40, height: 40)
                .clipShape(Circle())

              VStack(alignment: .leading) {
                Text("Manhattan Early College School")
                  .bold()
                  .lineLimit(1)

                Text("New York, NY")
                  .foregroundColor(Color.god.textSecondaryLight)
              }
              .font(.footnote)
              .frame(maxWidth: .infinity)

              VStack(spacing: 0) {
                Text("164")
                  .bold()
                  .foregroundColor(Color.god.service)
                Text("MEMBERS")
                  .foregroundColor(Color.god.textSecondaryLight)
              }
              .font(.footnote)
            }
          }
        }
        .listStyle(.plain)
        .foregroundColor(.primary)
        .background(Color.white)
        .multilineTextAlignment(.center)
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
      }
      .navigationTitle("Pick your school")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.god.service, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
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

struct SchoolSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SchoolSettingView(
        store: .init(
          initialState: SchoolSettingReducer.State(),
          reducer: { SchoolSettingReducer() }
        )
      )
    }
  }
}
