public enum AsyncValue<T: Equatable>: Equatable {
  case none
  case loading
  case success(T)
  case failure(Error)

  public var isLoading: Bool {
    self == .loading
  }

  public static func == (lhs: AsyncValue<T>, rhs: AsyncValue<T>) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
      return true
    case (.loading, .loading):
      return true
    case let (.success(lhs), .success(rhs)):
      return lhs == rhs
    default:
      return false
    }
  }
}
