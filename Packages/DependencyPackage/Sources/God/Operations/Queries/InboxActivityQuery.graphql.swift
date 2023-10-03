// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class InboxActivityQuery: GraphQLQuery {
    public static let operationName: String = "InboxActivity"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query InboxActivity($id: String!) { inboxActivity(id: $id) { __typename ...InboxFragment } }"#,
        fragments: [InboxFragment.self]
      ))

    public var id: String

    public init(id: String) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("inboxActivity", InboxActivity.self, arguments: ["id": .variable("id")]),
      ] }

      public var inboxActivity: InboxActivity { __data["inboxActivity"] }

      /// InboxActivity
      ///
      /// Parent Type: `InboxActivity`
      public struct InboxActivity: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivity }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(InboxFragment.self),
        ] }

        /// ID
        public var id: God.ID { __data["id"] }
        /// イニシャルを取得する。God Modeのみ。
        public var initial: String? { __data["initial"] }
        public var createdAt: God.Date { __data["createdAt"] }
        public var question: InboxFragment.Question { __data["question"] }
        public var voteUser: InboxFragment.VoteUser { __data["voteUser"] }
        /// 投票の際に表示されていた選択肢
        public var choices: [InboxFragment.Choice] { __data["choices"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var inboxFragment: InboxFragment { _toFragment() }
        }
      }
    }
  }

}