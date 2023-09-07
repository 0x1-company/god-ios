// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class UpdateUsernameMutation: GraphQLMutation {
    public static let operationName: String = "UpdateUsername"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateUsername($input: UpdateUsernameInput!) { updateUsername(input: $input) { __typename username } }"#
      ))

    public var input: UpdateUsernameInput

    public init(input: UpdateUsernameInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("updateUsername", UpdateUsername.self, arguments: ["input": .variable("input")]),
      ] }

      /// Usernameのアップデート
      public var updateUsername: UpdateUsername { __data["updateUsername"] }

      /// UpdateUsername
      ///
      /// Parent Type: `User`
      public struct UpdateUsername: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("username", String?.self),
        ] }

        /// username
        public var username: String? { __data["username"] }
      }
    }
  }

}