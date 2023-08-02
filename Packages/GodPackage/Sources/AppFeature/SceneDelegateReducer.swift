import ComposableArchitecture
import UIKit

public struct SceneDelegateReducer: Reducer {
  public struct State: Equatable {}
  public enum Action: Equatable {
    case shortcutItem(UIApplicationShortcutItem)
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    return .none
  }
}
