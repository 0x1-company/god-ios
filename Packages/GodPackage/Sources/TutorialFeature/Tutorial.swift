import AnalyticsClient
import ComposableArchitecture
import Styleguide
import SwiftUI

@Reducer
public struct TutorialLogic {
  public init() {}
  
  public enum Step: Int {
    case first, second, third, fourth, fifth
  }

  public struct State: Equatable {
    var currentStep = Step.first
    public init() {}
  }

  public enum Action {
    case onTask
    case onAppear
    case nextButtonTapped
    case skipButtonTapped
    case finishButtonTapped
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case finish
    }
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "Tutorial", of: self)
        return .none
        
      case .nextButtonTapped:
        guard let nextStep = Step(rawValue: state.currentStep.rawValue + 1)
        else { return .none }
        state.currentStep = nextStep
        return .none
        
      case .skipButtonTapped:
        return .send(.delegate(.finish), animation: .default)
        
      case .finishButtonTapped:
        return .send(.delegate(.finish), animation: .default)
        
      case .delegate:
        return .none
      }
    }
  }
}

public struct TutorialView: View {
  let store: StoreOf<TutorialLogic>

  public init(store: StoreOf<TutorialLogic>) {
    self.store = store
  }
  
  struct ViewState: Equatable {
    let currentStep: TutorialLogic.Step
    let isSkipButtonHidden: Bool
    let isOnTapGestureDisabled: Bool
    let isNextButtonHidden: Bool
    let isFinishButtonHidden: Bool
    
    init(state: TutorialLogic.State) {
      self.currentStep = state.currentStep
      self.isSkipButtonHidden = [TutorialLogic.Step.first, .fifth].contains(state.currentStep)
      self.isOnTapGestureDisabled = state.currentStep == .fifth
      self.isNextButtonHidden = state.currentStep != .first
      self.isFinishButtonHidden = state.currentStep != .fifth
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      VStack(spacing: 53) {
        Spacer()
        
        switch viewStore.currentStep {
        case .first:
          Step1View()
        case .second:
          Step2View()
        case .third:
          Step3View()
        case .fourth:
          Step4View()
        case .fifth:
          Step5View()
        }
        
        if !viewStore.isNextButtonHidden {
          VStack(spacing: 24) {
            Button {
              store.send(.nextButtonTapped, animation: .default)
            } label: {
              Text("Next", bundle: .module)
                .font(.system(.body, design: .rounded, weight: .bold))
                .frame(height: 56)
                .padding(.horizontal, 80)
                .foregroundStyle(Color.white)
                .background(Color.godService)
                .clipShape(Capsule())
            }
            .buttonStyle(HoldDownButtonStyle())
            
            Button {
              store.send(.skipButtonTapped)
            } label: {
              Text("Skip", bundle: .module)
                .foregroundStyle(Color.godTextSecondaryDark)
                .font(.system(.body, design: .rounded, weight: .bold))
            }
          }
        }
        
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .multilineTextAlignment(.center)
      .background(Color.black.opacity(0.9))
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .onTapGesture {
        if !viewStore.isOnTapGestureDisabled {
          store.send(.nextButtonTapped, animation: .default)
        }
      }
      .overlay(alignment: .topTrailing) {
        if !viewStore.isSkipButtonHidden {
          Button {
            store.send(.skipButtonTapped)
          } label: {
            Text("Skip", bundle: .module)
              .foregroundStyle(Color.godTextSecondaryDark)
              .font(.system(.body, design: .rounded, weight: .bold))
              .padding(.all, 24)
          }
        }
      }
      .overlay(alignment: .bottom) {
        if !viewStore.isFinishButtonHidden {
          Button {
            store.send(.finishButtonTapped)
          } label: {
            Text("Get started", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .foregroundStyle(Color.white)
              .background(Color.godService)
              .clipShape(Capsule())
          }
          .padding(.horizontal, 24)
          .buttonStyle(HoldDownButtonStyle())
        }
      }
    }
  }
}

#Preview {
  TutorialView(
    store: .init(
      initialState: TutorialLogic.State(),
      reducer: { TutorialLogic() }
    )
  )
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
