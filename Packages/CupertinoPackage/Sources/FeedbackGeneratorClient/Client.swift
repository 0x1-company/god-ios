public struct FeedbackGeneratorClient {
  public var prepare: @Sendable () async -> Void
  public var mediumImpact: @Sendable () async -> Void
}
