import AnalyticsClient
import ComposableArchitecture
import RoundedCorner
import Styleguide
import SwiftUI

public struct GradeSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case generationButtonTapped(Int?)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen(Int?)
    }
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "GradeSetting", of: self)
        return .none

      case let .generationButtonTapped(generation):
        return .run { send in
          await send(.delegate(.nextScreen(generation)))
        }
      case .delegate:
        return .none
      }
    }
  }
}

public struct GradeSettingView: View {
  let store: StoreOf<GradeSettingLogic>

  public init(store: StoreOf<GradeSettingLogic>) {
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
          Text("HIGH SCHOOL", bundle: .module)
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
      .navigationTitle(Text("What grade are you in?", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden()
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .onAppear { store.send(.onAppear) }
    }
  }

  @ViewBuilder
  func selectButton(
    _ title: LocalizedStringKey,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Text(title, bundle: .module)
        .bold()
        .frame(height: 65)
        .frame(maxWidth: .infinity)
    }
  }

  @ViewBuilder
  func gradeButton(
    _ title: LocalizedStringKey,
    year: LocalizedStringKey,
    action: @escaping () -> Void
  ) -> some View {
    selectButton(title, action: action)
      .overlay(alignment: .trailing) {
        Text(year, bundle: .module)
          .font(.footnote)
          .padding(.horizontal, 24)
          .foregroundColor(.secondary)
      }
  }
}

#Preview {
  NavigationStack {
    GradeSettingView(
      store: .init(
        initialState: GradeSettingLogic.State(),
        reducer: { GradeSettingLogic() }
      )
    )
  }
}
