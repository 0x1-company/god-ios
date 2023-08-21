// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class ApproveFriendRequestMutation: GraphQLMutation {
    public static let operationName: String = "ApproveFriendRequest"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ApproveFriendRequest($input: ApproveFriendRequestInput!) { approveFriendRequest(input: $input) { __typename id userId friendUserId status } }"#
      ))

    public var input: ApproveFriendRequestInput

    public init(input: ApproveFriendRequestInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("approveFriendRequest", ApproveFriendRequest.self, arguments: ["input": .variable("input")]),
      ] }

      /// フレンドリクエスト承認
      public var approveFriendRequest: ApproveFriendRequest { __data["approveFriendRequest"] }

      /// ApproveFriendRequest
      ///
      /// Parent Type: `Friend`
      public struct ApproveFriendRequest: God.SelectionSet {
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