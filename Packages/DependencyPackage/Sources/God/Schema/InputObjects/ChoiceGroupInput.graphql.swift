// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct ChoiceGroupInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      choices: [ChoiceInput],
      signature: SignatureInput
    ) {
      __data = InputDict([
        "choices": choices,
        "signature": signature
      ])
    }

    public var choices: [ChoiceInput] {
      get { __data["choices"] }
      set { __data["choices"] = newValue }
    }

    public var signature: SignatureInput {
      get { __data["signature"] }
      set { __data["signature"] = newValue }
    }
  }

}