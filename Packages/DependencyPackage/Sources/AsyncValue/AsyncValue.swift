public enum AsyncValue<T: Equatable>: Equatable {
  case none
  case loading
  case some(T)

  public var isLoading: Bool {
    self == .loading
  }
}
