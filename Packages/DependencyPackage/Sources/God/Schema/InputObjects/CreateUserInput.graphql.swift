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
      invitationCode: GraphQLNullable<String> = nil,
      inviterUserId: GraphQLNullable<String> = nil,
      phoneNumber: PhoneNumberInput
    ) {
      __data = InputDict([
        "invitationCode": invitationCode,
        "inviterUserId": inviterUserId,
        "phoneNumber": phoneNumber
      ])
    }

    /// 招待コード
    public var invitationCode: GraphQLNullable<String> {
      get { __data["invitationCode"] }
      set { __data["invitationCode"] = newValue }
    }

    /// 招待したユーザーのID
    public var inviterUserId: GraphQLNullable<String> {
      get { __data["inviterUserId"] }
      set { __data["inviterUserId"] = newValue }
    }

    /// Phone Number
    public var phoneNumber: PhoneNumberInput {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }
  }

}