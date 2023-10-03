// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct InboxFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment InboxFragment on InboxActivity { __typename id initial createdAt question { __typename id imageURL text { __typename ja } } voteUser { __typename id grade gender } choices { __typename id userId text orderIndex isSelected } }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivity }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("initial", String?.self),
      .field("createdAt", God.Date.self),
      .field("question", Question.self),
      .field("voteUser", VoteUser.self),
      .field("choices", [Choice].self),
    ] }

    /// ID
    public var id: God.ID { __data["id"] }
    /// イニシャルを取得する。God Modeのみ。
    public var initial: String? { __data["initial"] }
    public var createdAt: God.Date { __data["createdAt"] }
    public var question: Question { __data["question"] }
    public var voteUser: VoteUser { __data["voteUser"] }
    /// 投票の際に表示されていた選択肢
    public var choices: [Choice] { __data["choices"] }

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

    /// Choice
    ///
    /// Parent Type: `VoteChoice`
    public struct Choice: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.VoteChoice }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
        .field("userId", String.self),
        .field("text", String.self),
        .field("orderIndex", Int.self),
        .field("isSelected", Bool.self),
      ] }

      public var id: String { __data["id"] }
      public var userId: String { __data["userId"] }
      public var text: String { __data["text"] }
      public var orderIndex: Int { __data["orderIndex"] }
      public var isSelected: Bool { __data["isSelected"] }
    }
  }

}