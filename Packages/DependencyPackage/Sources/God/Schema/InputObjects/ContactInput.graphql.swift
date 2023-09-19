// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct ContactInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      name: String,
      phoneNumber: PhoneNumberInput
    ) {
      __data = InputDict([
        "name": name,
        "phoneNumber": phoneNumber
      ])
    }

    /// ニックネームもしくはフルネーム、表示用の名前
    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// 電話番号
    public var phoneNumber: PhoneNumberInput {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }
  }

}