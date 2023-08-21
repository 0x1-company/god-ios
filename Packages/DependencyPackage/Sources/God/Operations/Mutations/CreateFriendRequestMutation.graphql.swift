// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CreateFriendRequestMutation: GraphQLMutation {
    public static let operationName: String = "CreateFriendRequest"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateFriendRequest($input: CreateFriendRequestInput!) { createFriendRequest(input: $input) { __typename id userId friendUserId status } }"#
      ))

    public var input: CreateFriendRequestInput

    public init(input: CreateFriendRequestInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createFriendRequest", CreateFriendRequest.self, arguments: ["input": .variable("input")]),
      ] }

      /// フレンドリクエスト送信
      public var createFriendRequest: CreateFriendRequest { __data["createFriendRequest"] }

      /// CreateFriendRequest
      ///
      /// Parent Type: `Friend`
      public struct CreateFriendRequest: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.Friend }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("userId", String.self),
          .field("friendUserId", String.self),
          .field("status", GraphQLEnum<God.FriendStatus>.self),
        ] }

        public var id: God.ID { __data["id"] }
        public var userId: String { __data["userId"] }
        public var friendUserId: String { __data["friendUserId"] }
        /// フレンド状態
        public var status: GraphQLEnum<God.FriendStatus> { __data["status"] }
      }
    }
  }
}
