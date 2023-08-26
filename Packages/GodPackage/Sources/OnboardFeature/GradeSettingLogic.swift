import ComposableArchitecture

public struct GradeSettingLogic: Reducer {
  public func reduce(
    into state: inout OnboardReducer.State,
    action: OnboardReducer.Action
  ) -> Effect<OnboardReducer.Action> {
    switch action {
    case let .generationChanged(generation):
      state.generation = generation
      return .none
      
    default:
      return .none
    }
  }
}
