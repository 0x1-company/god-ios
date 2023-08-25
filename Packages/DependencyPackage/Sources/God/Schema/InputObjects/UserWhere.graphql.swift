// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct UserWhere: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      id: GraphQLNullable<ID> = nil,
      username: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "id": id,
        "username": username
      ])
    }

    public var id: GraphQLNullable<ID> {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }

    public var username: GraphQLNullable<String> {
      get { __data["username"] }
      set { __data["username"] = newValue }
    }
  }

}