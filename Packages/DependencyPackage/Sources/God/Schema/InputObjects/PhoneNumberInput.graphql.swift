// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct PhoneNumberInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      countryCode: String,
      numbers: String
    ) {
      __data = InputDict([
        "countryCode": countryCode,
        "numbers": numbers
      ])
    }

    /// 国別コード
    public var countryCode: String {
      get { __data["countryCode"] }
      set { __data["countryCode"] = newValue }
    }

    /// 番号
    public var numbers: String {
      get { __data["numbers"] }
      set { __data["numbers"] = newValue }
    }
  }

}