// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class UpdateUserProfileMutation: GraphQLMutation {
    public static let operationName: String = "UpdateUserProfile"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateUserProfile($input: UpdateUserProfileInput!) { updateUserProfile(input: $input) { __typename firstName lastName gender schoolId } }"#
      ))

    public var input: UpdateUserProfileInput

    public init(input: UpdateUserProfileInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("updateUserProfile", UpdateUserProfile.self, arguments: ["input": .variable("input")]),
      ] }

      /// update a user profile
      public var updateUserProfile: UpdateUserProfile { __data["updateUserProfile"] }

      /// UpdateUserProfile
      ///
      /// Parent Type: `User`
      public struct UpdateUserProfile: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("gender", GraphQLEnum<God.Gender>.self),
          .field("schoolId", String?.self),
        ] }

        /// first name
        public var firstName: String { __data["firstName"] }
        /// last name
        public var lastName: String { __data["lastName"] }
        /// gender
        public var gender: GraphQLEnum<God.Gender> { __data["gender"] }
        public var schoolId: String? { __data["schoolId"] }
      }
    }
  }

}