import Colors
import ComposableArchitecture
import RoundedCorner
import SwiftUI

public struct GradeSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case infoButtonTapped
    case notInHighSchoolButtonTapped
    case grade10ButtonTapped
    case grade11ButtonTapped
    case grade12ButtonTapped
    case finishedHighSchoolButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextSchoolSetting
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
        
      case .infoButtonTapped:
        return .none

      case .notInHighSchoolButtonTapped:
        return .run { send in
          await send(.delegate(.nextSchoolSetting))
        }
      case .grade10ButtonTapped:
        return .run { send in
          await send(.delegate(.nextSchoolSetting))
        }
      case .grade11ButtonTapped:
        return .run { send in
          await send(.delegate(.nextSchoolSetting))
        }
      case .grade12ButtonTapped:
        return .run { send in
          await send(.delegate(.nextSchoolSetting))
        }
      case .finishedHighSchoolButtonTapped:
        return .run { send in
          await send(.delegate(.nextSchoolSetting))
        }
      case .delegate:
        return .none
      }
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
        Color.god.service

        VStack(spacing: 0) {
          selectButton("Not in High School") {
            viewStore.send(.notInHighSchoolButtonTapped)
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
              viewStore.send(.grade10ButtonTapped)
            }
            Divider()
            gradeButton("Grade 11", year: "CLASS OF\n2024") {
              viewStore.send(.grade11ButtonTapped)
            }
            Divider()
            gradeButton("Grade 12", year: "CLASS OF\n2023") {
              viewStore.send(.grade12ButtonTapped)
            }
            Divider()
            selectButton("Finished High School") {
              viewStore.send(.finishedHighSchoolButtonTapped)
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
