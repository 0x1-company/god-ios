import AnalyticsClient
import ComposableArchitecture
import RoundedCorner
import Styleguide
import SwiftUI

@Reducer
public struct GradeSettingLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {
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
    WithViewStore(store, observe: { $0 }) { _ in
      ZStack(alignment: .center) {
        Color.godService

        VStack(spacing: 0) {
          selectButton("Not in High School") {
            store.send(.generationButtonTapped(nil))
          }
          Divider()
          Text("HIGH SCHOOL", bundle: .module)
            .frame(height: 33)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .foregroundStyle(.secondary)
            .background(Color(uiColor: .quaternarySystemFill))

          Divider()

          VStack(spacing: 0) {
            gradeButton("Grade 10", year: "CLASS OF\n2025") {
              store.send(.generationButtonTapped(2007))
            }
            Divider()
            gradeButton("Grade 11", year: "CLASS OF\n2024") {
              store.send(.generationButtonTapped(2006))
            }
            Divider()
            gradeButton("Grade 12", year: "CLASS OF\n2023") {
              store.send(.generationButtonTapped(2005))
            }
            Divider()
            selectButton("Finished High School") {
              store.send(.generationButtonTapped(nil))
            }
            Divider()
          }
          Spacer()
        }
        .foregroundStyle(.primary)
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
        .frame(height: 65)
        .frame(maxWidth: .infinity)
        .font(.system(.body, design: .rounded, weight: .bold))
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
          .foregroundStyle(.secondary)
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
