// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct RevealFullNameInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      activityId: String
    ) {
      __data = InputDict([
        "activityId": activityId
      ])
    }

    public var activityId: String {
      get { __data["activityId"] }
      set { __data["activityId"] = newValue }
    }
  }

}