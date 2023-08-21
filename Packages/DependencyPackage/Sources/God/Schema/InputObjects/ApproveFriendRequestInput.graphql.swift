// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct ApproveFriendRequestInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      id: String
    ) {
      __data = InputDict([
        "id": id,
      ])
    }

    /// リクエストを承認するID
    public var id: String {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }
  }
}
