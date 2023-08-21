// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct CreateUserBlockInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      blockedUserId: String
    ) {
      __data = InputDict([
        "blockedUserId": blockedUserId
      ])
    }

    /// ブロックしたいユーザーのID
    public var blockedUserId: String {
      get { __data["blockedUserId"] }
      set { __data["blockedUserId"] = newValue }
    }
  }

}