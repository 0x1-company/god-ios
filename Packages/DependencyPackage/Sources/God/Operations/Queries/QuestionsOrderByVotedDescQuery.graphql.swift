// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class QuestionsOrderByVotedDescQuery: GraphQLQuery {
    public static let operationName: String = "QuestionsOrderByVotedDesc"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query QuestionsOrderByVotedDesc($first: Int!) { questionsOrderByVotedDesc(first: $first) { __typename id imageURL text { __typename ja } } }"#
      ))

    public var first: Int

    public init(first: Int) {
      self.first = first
    }

    public var __variables: Variables? { ["first": first] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("questionsOrderByVotedDesc", [QuestionsOrderByVotedDesc].self, arguments: ["first": .variable("first")]),
      ] }

      public var questionsOrderByVotedDesc: [QuestionsOrderByVotedDesc] { __data["questionsOrderByVotedDesc"] }

      /// QuestionsOrderByVotedDesc
      ///
      /// Parent Type: `Question`
      public struct QuestionsOrderByVotedDesc: God.SelectionSet {
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

        /// QuestionsOrderByVotedDesc.Text
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

}