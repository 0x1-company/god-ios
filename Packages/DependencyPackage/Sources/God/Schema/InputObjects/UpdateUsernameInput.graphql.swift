// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct UpdateUsernameInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      username: String
    ) {
      __data = InputDict([
        "username": username
      ])
    }

    public var username: String {
      get { __data["username"] }
      set { __data["username"] = newValue }
    }
  }

}