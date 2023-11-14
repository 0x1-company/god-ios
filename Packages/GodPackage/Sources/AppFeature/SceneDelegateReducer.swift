import ComposableArchitecture
import UIKit

@Reducer
public struct SceneDelegateLogic {
  public struct State: Equatable {}
  public enum Action: Equatable {
    case shortcutItem(UIApplicationShortcutItem)
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    .none
  }
}
