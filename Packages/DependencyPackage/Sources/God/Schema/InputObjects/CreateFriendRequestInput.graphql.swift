// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct CreateFriendRequestInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      toUserId: String
    ) {
      __data = InputDict([
        "toUserId": toUserId,
      ])
    }

    /// 友達にしたいユーザーのID
    public var toUserId: String {
      get { __data["toUserId"] }
      set { __data["toUserId"] = newValue }
    }
  }
}
