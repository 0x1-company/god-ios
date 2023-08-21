// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct CreateUserHideInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      hiddenUserId: String
    ) {
      __data = InputDict([
        "hiddenUserId": hiddenUserId
      ])
    }

    /// 非表示にしたいユーザーのID
    public var hiddenUserId: String {
      get { __data["hiddenUserId"] }
      set { __data["hiddenUserId"] = newValue }
    }
  }

}