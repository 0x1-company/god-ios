public struct UIPasteboardClient {
  public var string: @Sendable (String?) -> Void
  public var strings: @Sendable ([String]?) -> Void
}
