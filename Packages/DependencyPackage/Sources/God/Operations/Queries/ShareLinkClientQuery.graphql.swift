// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class ShareLinkClientQuery: GraphQLQuery {
    public static let operationName: String = "ShareLinkClient"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ShareLinkClient { currentUser { __typename id username } invitationCode { __typename id code } }"#
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("currentUser", CurrentUser.self),
        .field("invitationCode", InvitationCode.self),
      ] }

      /// ログイン中ユーザーを取得
      public var currentUser: CurrentUser { __data["currentUser"] }
      /// 招待コードを取得
      public var invitationCode: InvitationCode { __data["invitationCode"] }

      /// CurrentUser
      ///
      /// Parent Type: `User`
      public struct CurrentUser: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("username", String?.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
        /// username
        public var username: String? { __data["username"] }
      }

      /// InvitationCode
      ///
      /// Parent Type: `InvitationCode`
      public struct InvitationCode: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.InvitationCode }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("code", String.self),
        ] }

        public var id: God.ID { __data["id"] }
        /// 招待コード
        public var code: String { __data["code"] }
      }
    }
  }

}