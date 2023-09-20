// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct ChoiceGroupFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ChoiceGroupFragment on ChoiceGroup { __typename signature { __typename digest } choices { __typename userId text } }"#
    }

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

    /// Signature
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

    /// Choice
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