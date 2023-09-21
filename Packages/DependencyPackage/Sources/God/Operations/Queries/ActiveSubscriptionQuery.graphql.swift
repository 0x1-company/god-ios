// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class ActiveSubscriptionQuery: GraphQLQuery {
    public static let operationName: String = "ActiveSubscription"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ActiveSubscription { activeSubscription { __typename id expireAt transactionId productId } }"#
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("activeSubscription", ActiveSubscription?.self),
      ] }

      /// 有効な購読情報を取得
      public var activeSubscription: ActiveSubscription? { __data["activeSubscription"] }

      /// ActiveSubscription
      ///
      /// Parent Type: `Subscription`
      public struct ActiveSubscription: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.Subscription }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("expireAt", God.Date.self),
          .field("transactionId", String.self),
          .field("productId", String.self),
        ] }

        public var id: God.ID { __data["id"] }
        public var expireAt: God.Date { __data["expireAt"] }
        public var transactionId: String { __data["transactionId"] }
        public var productId: String { __data["productId"] }
      }
    }
  }

}