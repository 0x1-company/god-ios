// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct CreateUserInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      phoneNumber: PhoneNumberInput
    ) {
      __data = InputDict([
        "phoneNumber": phoneNumber,
      ])
    }

    /// Phone Number
    public var phoneNumber: PhoneNumberInput {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }
  }
}
