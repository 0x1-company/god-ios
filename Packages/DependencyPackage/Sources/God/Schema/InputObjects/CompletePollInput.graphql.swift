// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct CompletePollInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      pollId: String
    ) {
      __data = InputDict([
        "pollId": pollId
      ])
    }

    public var pollId: String {
      get { __data["pollId"] }
      set { __data["pollId"] = newValue }
    }
  }

}