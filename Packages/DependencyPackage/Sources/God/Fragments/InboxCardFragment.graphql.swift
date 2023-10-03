// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct InboxCardFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment InboxCardFragment on InboxActivity { __typename id isRead createdAt question { __typename id text { __typename ja } } voteUser { __typename id grade gender } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivity }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("isRead", Bool.self),
      .field("createdAt", God.Date.self),
      .field("question", Question.self),
      .field("voteUser", VoteUser.self),
    ] }

    /// ID
    public var id: God.ID { __data["id"] }
    /// 既読かどうか
    public var isRead: Bool { __data["isRead"] }
    public var createdAt: God.Date { __data["createdAt"] }
    public var question: Question { __data["question"] }
    public var voteUser: VoteUser { __data["voteUser"] }

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
        .field("text", Text.self),
      ] }

      public var id: God.ID { __data["id"] }
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

    /// VoteUser
    ///
    /// Parent Type: `PublicVoteUser`
    public struct VoteUser: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.PublicVoteUser }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", God.ID.self),
        .field("grade", String?.self),
        .field("gender", GraphQLEnum<God.Gender>.self),
      ] }

      /// user id
      public var id: God.ID { __data["id"] }
      /// 学年をテキストで返す
      public var grade: String? { __data["grade"] }
      /// gender
      public var gender: GraphQLEnum<God.Gender> { __data["gender"] }
    }
  }

}