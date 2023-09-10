import Colors
import ComposableArchitecture
import RoundedCorner
import SwiftUI

public struct SchoolSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var schoolHelp: SchoolHelpSheetLogic.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case infoButtonTapped
    case schoolButtonTapped
    case schoolHelp(PresentationAction<SchoolHelpSheetLogic.Action>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen(id: String?)
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none
      case .infoButtonTapped:
        state.schoolHelp = .init()
        return .none
      case .schoolButtonTapped:
        return .send(.delegate(.nextScreen(id: nil)))
      case .schoolHelp:
        return .none
      case .delegate:
        return .none
      }
    }
    .ifLet(\.$schoolHelp, action: /Action.schoolHelp) {
      SchoolHelpSheetLogic()
    }
  }
}

public struct SchoolSettingView: View {
  let store: StoreOf<SchoolSettingLogic>

  public init(store: StoreOf<SchoolSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        Color.godService

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
                  .foregroundColor(Color.godTextSecondaryLight)
              }
              .font(.footnote)
              .frame(maxWidth: .infinity)

              VStack(spacing: 0) {
                Text("164")
                  .bold()
                  .foregroundColor(Color.godService)
                Text("MEMBERS")
                  .foregroundColor(Color.godTextSecondaryLight)
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
      .toolbarBackground(Color.godService, for: .navigationBar)
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
      .sheet(
        store: store.scope(
          state: \.$schoolHelp,
          action: SchoolSettingLogic.Action.schoolHelp
        )
      ) { store in
        SchoolHelpSheetView(store: store)
          .presentationDetents([.fraction(0.4)])
          .presentationDragIndicator(.visible)
      }
    }
  }
}

struct SchoolSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SchoolSettingView(
        store: .init(
          initialState: SchoolSettingLogic.State(),
          reducer: { SchoolSettingLogic() }
        )
      )
    }
  }
}
