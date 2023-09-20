// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CompletePollMutation: GraphQLMutation {
    public static let operationName: String = "CompletePoll"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CompletePoll($input: CompletePollInput!) { completePoll(input: $input) { __typename earnedCoinAmount } }"#
      ))

    public var input: CompletePollInput

    public init(input: CompletePollInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("completePoll", CompletePoll.self, arguments: ["input": .variable("input")]),
      ] }

      /// pollのcomplete処理を行い、コインを付与する
      public var completePoll: CompletePoll { __data["completePoll"] }

      /// CompletePoll
      ///
      /// Parent Type: `CompletePollResponse`
      public struct CompletePoll: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.CompletePollResponse }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("earnedCoinAmount", Int.self),
        ] }

        /// 獲得コイン枚数
        public var earnedCoinAmount: Int { __data["earnedCoinAmount"] }
      }
    }
  }

}