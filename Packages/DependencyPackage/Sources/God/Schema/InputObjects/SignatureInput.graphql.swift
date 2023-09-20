// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct SignatureInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      digest: String
    ) {
      __data = InputDict([
        "digest": digest
      ])
    }

    public var digest: String {
      get { __data["digest"] }
      set { __data["digest"] = newValue }
    }
  }

}