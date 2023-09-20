// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct CreateVoteInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      choiceGroup: ChoiceGroupInput,
      pollQuestionId: String,
      votedUserId: String
    ) {
      __data = InputDict([
        "choiceGroup": choiceGroup,
        "pollQuestionId": pollQuestionId,
        "votedUserId": votedUserId
      ])
    }

    /// 実際に投票するときに使った選択肢
    public var choiceGroup: ChoiceGroupInput {
      get { __data["choiceGroup"] }
      set { __data["choiceGroup"] = newValue }
    }

    public var pollQuestionId: String {
      get { __data["pollQuestionId"] }
      set { __data["pollQuestionId"] = newValue }
    }

    /// 投票された人のID
    public var votedUserId: String {
      get { __data["votedUserId"] }
      set { __data["votedUserId"] = newValue }
    }
  }

}