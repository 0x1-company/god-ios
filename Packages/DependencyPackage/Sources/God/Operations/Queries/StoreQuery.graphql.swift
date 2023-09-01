// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class StoreQuery: GraphQLQuery {
    public static let operationName: String = "Store"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Store { store { __typename items { __typename id coinAmount status status quantity itemType title { __typename ja } description { __typename ja } } } }"#
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("store", Store.self),
      ] }

      /// ストアのすべての商品を取得する
      public var store: Store { __data["store"] }

      /// Store
      ///
      /// Parent Type: `Store`
      public struct Store: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.Store }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("items", [Item].self),
        ] }

        /// 商品一覧
        public var items: [Item] { __data["items"] }

        /// Store.Item
        ///
        /// Parent Type: `StoreItem`
        public struct Item: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.StoreItem }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", God.ID.self),
            .field("coinAmount", Int.self),
            .field("status", GraphQLEnum<God.StoreItemStatus>.self),
            .field("quantity", Int.self),
            .field("itemType", GraphQLEnum<God.ItemType>.self),
            .field("title", Title.self),
            .field("description", Description?.self),
          ] }

          public var id: God.ID { __data["id"] }
          /// 価格(コイン)
          public var coinAmount: Int { __data["coinAmount"] }
          /// ステータス
          public var status: GraphQLEnum<God.StoreItemStatus> { __data["status"] }
          /// 数
          public var quantity: Int { __data["quantity"] }
          /// アイテムの種類
          public var itemType: GraphQLEnum<God.ItemType> { __data["itemType"] }
          /// タイトル
          public var title: Title { __data["title"] }
          /// 説明
          public var description: Description? { __data["description"] }

          /// Store.Item.Title
          ///
          /// Parent Type: `LocalizableString`
          public struct Title: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.LocalizableString }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("ja", String.self),
            ] }

            /// 日本語
            public var ja: String { __data["ja"] }
          }

          /// Store.Item.Description
          ///
          /// Parent Type: `LocalizableString`
          public struct Description: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.LocalizableString }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("ja", String.self),
            ] }

            /// 日本語
            public var ja: String { __data["ja"] }
          }
        }
      }
    }
  }

}