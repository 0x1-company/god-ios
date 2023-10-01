// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct InboxFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment InboxFragment on InboxActivity { __typename id initial isRead createdAt question { __typename id imageURL text { __typename ja } } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivity }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("initial", String?.self),
      .field("isRead", Bool.self),
      .field("createdAt", God.Date.self),
      .field("question", Question.self),
    ] }

    /// ID
    public var id: God.ID { __data["id"] }
    /// イニシャルを取得する。God Modeのみ。
    public var initial: String? { __data["initial"] }
    /// 既読かどうか
    public var isRead: Bool { __data["isRead"] }
    public var createdAt: God.Date { __data["createdAt"] }
    public var question: Question { __data["question"] }

    /// Question
    ///
    /// Parent Type: `Question`
    public struct Question: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Question }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", God.ID.self),
        .field("imageURL", String.self),
        .field("text", Text.self),
      ] }

      public var id: God.ID { __data["id"] }
      /// imageURL
      public var imageURL: String { __data["imageURL"] }
      /// text
      public var text: Text { __data["text"] }

      /// Question.Text
      ///
      /// Parent Type: `LocalizableString`
      public struct Text: God.SelectionSet {
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