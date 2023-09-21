// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class RevealFullNameLimitQuery: GraphQLQuery {
    public static let operationName: String = "RevealFullNameLimit"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query RevealFullNameLimit { revealFullNameLimit }"#
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("revealFullNameLimit", Int.self),
      ] }

      /// リビール可能数を取得
      public var revealFullNameLimit: Int { __data["revealFullNameLimit"] }
    }
  }

}