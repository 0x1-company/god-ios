// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CurrentUserProfileQuery: GraphQLQuery {
    public static let operationName: String = "CurrentUserProfile"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CurrentUserProfile { currentUser { __typename ...ProfileSectionFragment wallet { __typename coinBalance } } friends { __typename ...FriendFragment } questionsOrderByVotedDesc(first: 3) { __typename id imageURL text { __typename ja } } }"#,
        fragments: [ProfileSectionFragment.self, FriendFragment.self]
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("currentUser", CurrentUser.self),
        .field("friends", [Friend].self),
        .field("questionsOrderByVotedDesc", [QuestionsOrderByVotedDesc].self, arguments: ["first": 3]),
      ] }

      /// ログイン中ユーザーを取得
      public var currentUser: CurrentUser { __data["currentUser"] }
      /// フレンドの一覧
      public var friends: [Friend] { __data["friends"] }
      public var questionsOrderByVotedDesc: [QuestionsOrderByVotedDesc] { __data["questionsOrderByVotedDesc"] }

      /// CurrentUser
      ///
      /// Parent Type: `User`
      public struct CurrentUser: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("wallet", Wallet?.self),
          .fragment(ProfileSectionFragment.self),
        ] }

        /// wallet
        public var wallet: Wallet? { __data["wallet"] }
        /// user id
        public var id: God.ID { __data["id"] }
        /// 投票された数
        public var votedCount: Int { __data["votedCount"] }
        /// プロフィール画像のURL
        public var imageURL: String { __data["imageURL"] }
        /// 表示名
        public var displayName: ProfileSectionFragment.DisplayName { __data["displayName"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// username
        public var username: String? { __data["username"] }
        /// 年代
        public var generation: Int? { __data["generation"] }
        /// フレンド数
        public var friendsCount: Int? { __data["friendsCount"] }
        public var schoolId: String? { __data["schoolId"] }
        /// 学年をテキストで返す
        public var grade: String? { __data["grade"] }
        /// 所属している学校
        public var school: ProfileSectionFragment.School? { __data["school"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var profileSectionFragment: ProfileSectionFragment { _toFragment() }
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
            .field("coinBalance", Int.self),
          ] }

          /// コイン枚数
          public var coinBalance: Int { __data["coinBalance"] }
        }
      }

      /// Friend
      ///
      /// Parent Type: `User`
      public struct Friend: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(FriendFragment.self),
        ] }

        /// user id
        public var id: God.ID { __data["id"] }
        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// 表示名
        public var displayName: FriendFragment.DisplayName { __data["displayName"] }
        /// プロフィール画像のURL
        public var imageURL: String { __data["imageURL"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var friendFragment: FriendFragment { _toFragment() }
        }
      }

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