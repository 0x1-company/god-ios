// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CurrentPollQuery: GraphQLQuery {
    public static let operationName: String = "CurrentPoll"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CurrentPoll { currentPoll { __typename status coolDown { __typename until } poll { __typename id pollQuestions { __typename id question { __typename id id } choiceGroups { __typename signature { __typename digest } choices { __typename userId text } } } } } }"#
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("currentPoll", CurrentPoll.self),
      ] }

      /// 現在のPollを取得
      public var currentPoll: CurrentPoll { __data["currentPoll"] }

      /// CurrentPoll
      ///
      /// Parent Type: `CurrentPoll`
      public struct CurrentPoll: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.CurrentPoll }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", GraphQLEnum<God.CurrentPollStatus>.self),
          .field("coolDown", CoolDown?.self),
          .field("poll", Poll?.self),
        ] }

        /// has poll or cool down
        public var status: GraphQLEnum<God.CurrentPollStatus> { __data["status"] }
        /// クールダウン情報
        public var coolDown: CoolDown? { __data["coolDown"] }
        /// poll
        public var poll: Poll? { __data["poll"] }

        /// CurrentPoll.CoolDown
        ///
        /// Parent Type: `CoolDown`
        public struct CoolDown: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.CoolDown }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("until", God.Date.self),
          ] }

          /// いつまでクールダウンか
          public var until: God.Date { __data["until"] }
        }

        /// CurrentPoll.Poll
        ///
        /// Parent Type: `Poll`
        public struct Poll: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.Poll }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", God.ID.self),
            .field("pollQuestions", [PollQuestion].self),
          ] }

          public var id: God.ID { __data["id"] }
          /// 12の質問
          public var pollQuestions: [PollQuestion] { __data["pollQuestions"] }

          /// CurrentPoll.Poll.PollQuestion
          ///
          /// Parent Type: `PollQuestion`
          public struct PollQuestion: God.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { God.Objects.PollQuestion }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", God.ID.self),
              .field("question", Question.self),
              .field("choiceGroups", [ChoiceGroup].self),
            ] }

            /// ID
            public var id: God.ID { __data["id"] }
            public var question: Question { __data["question"] }
            /// 選択肢
            public var choiceGroups: [ChoiceGroup] { __data["choiceGroups"] }

            /// CurrentPoll.Poll.PollQuestion.Question
            ///
            /// Parent Type: `Question`
            public struct Question: God.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { God.Objects.Question }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", God.ID.self),
              ] }

              public var id: God.ID { __data["id"] }
            }

            /// CurrentPoll.Poll.PollQuestion.ChoiceGroup
            ///
            /// Parent Type: `ChoiceGroup`
            public struct ChoiceGroup: God.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { God.Objects.ChoiceGroup }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("signature", Signature.self),
                .field("choices", [Choice].self),
              ] }

              /// 改ざん検知用のハッシュ
              public var signature: Signature { __data["signature"] }
              /// 選択肢の一覧
              public var choices: [Choice] { __data["choices"] }

              /// CurrentPoll.Poll.PollQuestion.ChoiceGroup.Signature
              ///
              /// Parent Type: `Signature`
              public struct Signature: God.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { God.Objects.Signature }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("digest", String.self),
                ] }

                public var digest: String { __data["digest"] }
              }

              /// CurrentPoll.Poll.PollQuestion.ChoiceGroup.Choice
              ///
              /// Parent Type: `Choice`
              public struct Choice: God.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { God.Objects.Choice }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("userId", God.ID.self),
                  .field("text", String.self),
                ] }

                /// その選択肢に対応するユーザID
                public var userId: God.ID { __data["userId"] }
                /// 表示する名前
                public var text: String { __data["text"] }
              }
            }
          }
        }
      }
    }
  }

}