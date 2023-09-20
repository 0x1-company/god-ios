// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct ChoiceInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      text: String,
      userId: ID
    ) {
      __data = InputDict([
        "text": text,
        "userId": userId
      ])
    }

    /// 表示する名前
    public var text: String {
      get { __data["text"] }
      set { __data["text"] = newValue }
    }

    /// その選択肢に対応するユーザID
    public var userId: ID {
      get { __data["userId"] }
      set { __data["userId"] = newValue }
    }
  }

}