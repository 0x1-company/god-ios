import Colors
import ComposableArchitecture
import RoundedCorner
import SwiftUI

public struct GradeSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var gradeHelp: GradeHelpSheetReducer.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case infoButtonTapped
    case generationButtonTapped(Int?)
    case gradeHelp(PresentationAction<GradeHelpSheetReducer.Action>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen(Int?)
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case .infoButtonTapped:
        state.gradeHelp = .init()
        return .none

      case let .generationButtonTapped(generation):
        return .run { send in
          await send(.delegate(.nextScreen(generation)))
        }
      case .gradeHelp:
        return .none
      case .delegate:
        return .none
      }
    }
    .ifLet(\.$gradeHelp, action: /Action.gradeHelp) {
      GradeHelpSheetReducer()
    }
  }
}

public struct GradeSettingView: View {
  let store: StoreOf<GradeSettingReducer>

  public init(store: StoreOf<GradeSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        Color.godService

        VStack(spacing: 0) {
          selectButton("Not in High School") {
            viewStore.send(.generationButtonTapped(nil))
          }
          Divider()
          Text("HIGH SCHOOL")
            .frame(height: 33)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .foregroundColor(.secondary)
            .background(Color(uiColor: .quaternarySystemFill))

          Divider()

          VStack(spacing: 0) {
            gradeButton("Grade 10", year: "CLASS OF\n2025") {
              viewStore.send(.generationButtonTapped(2007))
            }
            Divider()
            gradeButton("Grade 11", year: "CLASS OF\n2024") {
              viewStore.send(.generationButtonTapped(2006))
            }
            Divider()
            gradeButton("Grade 12", year: "CLASS OF\n2023") {
              viewStore.send(.generationButtonTapped(2005))
            }
            Divider()
            selectButton("Finished High School") {
              viewStore.send(.generationButtonTapped(nil))
            }
            Divider()
          }
          Spacer()
        }
        .foregroundColor(.primary)
        .background(Color.white)
        .multilineTextAlignment(.center)
        .cornerRadius(12, corners: [.topLeft, .topRight])
      }
      .navigationTitle("What grade are you in?")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden()
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
          state: \.$gradeHelp,
          action: GradeSettingReducer.Action.gradeHelp
        )
      ) { store in
        GradeHelpSheetView(store: store)
          .presentationDragIndicator(.visible)
          .presentationDetents([.fraction(0.4)])
      }
    }
  }

  @ViewBuilder
  func selectButton(
    _ title: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Text(title)
        .bold()
        .frame(height: 65)
        .frame(maxWidth: .infinity)
    }
  }

  @ViewBuilder
  func gradeButton(
    _ title: String,
    year: String,
    action: @escaping () -> Void
  ) -> some View {
    selectButton(title, action: action)
      .overlay(alignment: .trailing) {
        Text(year)
          .font(.footnote)
          .padding(.horizontal, 24)
          .foregroundColor(.secondary)
      }
  }
}

struct GradeSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      GradeSettingView(
        store: .init(
          initialState: GradeSettingReducer.State(),
          reducer: { GradeSettingReducer() }
        )
      )
    }
  }
}
