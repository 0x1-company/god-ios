// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CurrentUserQuery: GraphQLQuery {
    public static let operationName: String = "CurrentUser"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CurrentUser { currentUser { __typename id firstName lastName username imageURL generation gender friendsCount schoolId school { __typename id name shortName profileImageURL } wallet { __typename id coinBalance } ...ProfileSectionFragment } }"#,
        fragments: [ProfileSectionFragment.self]
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("currentUser", CurrentUser.self),
      ] }

      /// ログイン中ユーザーを取得
      public var currentUser: CurrentUser { __data["currentUser"] }

      /// CurrentUser
      ///
      /// Parent Type: `User`
      public struct CurrentUser: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("username", String?.self),
          .field("imageURL", String.self),
          .field("generation", Int?.self),
          .field("gender", GraphQLEnum<God.Gender>.self),
          .field("friendsCount", Int?.self),
          .field("schoolId", String?.self),
          .field("school", School?.self),
          .field("wallet", Wallet?.self),
          .fragment(ProfileSectionFragment.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// username
        public var username: String? { __data["username"] }
        /// プロフィール画像のURL
        public var imageURL: String { __data["imageURL"] }
        /// 年代
        public var generation: Int? { __data["generation"] }
        /// gender
        public var gender: GraphQLEnum<God.Gender> { __data["gender"] }
        /// フレンド数
        public var friendsCount: Int? { __data["friendsCount"] }
        public var schoolId: String? { __data["schoolId"] }
        /// 所属している学校
        public var school: School? { __data["school"] }
        /// wallet
        public var wallet: Wallet? { __data["wallet"] }
        /// 投票された数
        public var votedCount: Int { __data["votedCount"] }
        /// 表示名
        public var displayName: ProfileSectionFragment.DisplayName { __data["displayName"] }
        /// 学年をテキストで返す
        public var grade: String? { __data["grade"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var profileSectionFragment: ProfileSectionFragment { _toFragment() }
        }

        /// CurrentUser.School
        ///
        /// Parent Type: `School`
        public struct School: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.School }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", God.ID.self),
            .field("name", String.self),
            .field("shortName", String.self),
            .field("profileImageURL", String.self),
          ] }

          public var id: God.ID { __data["id"] }
          /// 学校名
          public var name: String { __data["name"] }
          /// 学校名（略称）
          public var shortName: String { __data["shortName"] }
          /// アイコン画像URL
          public var profileImageURL: String { __data["profileImageURL"] }
        }

        /// CurrentUser.Wallet
        ///
        /// Parent Type: `Wallet`
        public struct Wallet: God.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { God.Objects.Wallet }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", God.ID.self),
            .field("coinBalance", Int.self),
          ] }

          public var id: God.ID { __data["id"] }
          /// コイン枚数
          public var coinBalance: Int { __data["coinBalance"] }
        }
      }
    }
  }

}