import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var feedbackGenerator: FeedbackGeneratorClient {
    get { self[FeedbackGeneratorClient.self] }
    set { self[FeedbackGeneratorClient.self] = newValue }
  }
}

extension FeedbackGeneratorClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    prepare: unimplemented("\(Self.self).prepare"),
    mediumImpact: unimplemented("\(Self.self).mediumImpact")
  )
}

public extension FeedbackGeneratorClient {
  static let noop = Self(
    prepare: {},
    mediumImpact: {}
  )
}
