// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GodPackage",
  defaultLocalization: "en",
  platforms: [
    .iOS("16.4"),
  ],
  products: [
    .library(name: "AboutFeature", targets: ["AboutFeature"]),
    .library(name: "ActivatedGodModeFeature", targets: ["ActivatedGodModeFeature"]),
    .library(name: "ActivityFeature", targets: ["ActivityFeature"]),
    .library(name: "AddFeature", targets: ["AddFeature"]),
    .library(name: "AllowAccessFeature", targets: ["AllowAccessFeature"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "CashOutFeature", targets: ["CashOutFeature"]),
    .library(name: "CupertinoMessageFeature", targets: ["CupertinoMessageFeature"]),
    .library(name: "DeleteAccountFeature", targets: ["DeleteAccountFeature"]),
    .library(name: "EmailFeature", targets: ["EmailFeature"]),
    .library(name: "FindFriendFeature", targets: ["FindFriendFeature"]),
    .library(name: "FindLocationFeature", targets: ["FindLocationFeature"]),
    .library(name: "ForceUpdateFeature", targets: ["ForceUpdateFeature"]),
    .library(name: "FriendRequestFeature", targets: ["FriendRequestFeature"]),
    .library(name: "GodFeature", targets: ["GodFeature"]),
    .library(name: "GodModeFeature", targets: ["GodModeFeature"]),
    .library(name: "GradeSettingFeature", targets: ["GradeSettingFeature"]),
    .library(name: "HowItWorksFeature", targets: ["HowItWorksFeature"]),
    .library(name: "InAppWebFeature", targets: ["InAppWebFeature"]),
    .library(name: "InboxDetailFeature", targets: ["InboxDetailFeature"]),
    .library(name: "InboxFeature", targets: ["InboxFeature"]),
    .library(name: "InboxStoryFeature", targets: ["InboxStoryFeature"]),
    .library(name: "InviteFriendFeature", targets: ["InviteFriendFeature"]),
    .library(name: "LaunchFeature", targets: ["LaunchFeature"]),
    .library(name: "MaintenanceFeature", targets: ["MaintenanceFeature"]),
    .library(name: "ManageAccountFeature", targets: ["ManageAccountFeature"]),
    .library(name: "NavigationFeature", targets: ["NavigationFeature"]),
    .library(name: "OnboardFeature", targets: ["OnboardFeature"]),
    .library(name: "PlayAgainFeature", targets: ["PlayAgainFeature"]),
    .library(name: "PollFeature", targets: ["PollFeature"]),
    .library(name: "ProfileEditFeature", targets: ["ProfileEditFeature"]),
    .library(name: "ProfileExternalFeature", targets: ["ProfileExternalFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ProfileSharedFeature", targets: ["ProfileSharedFeature"]),
    .library(name: "ProfileShareFeature", targets: ["ProfileShareFeature"]),
    .library(name: "ProfileStoryFeature", targets: ["ProfileStoryFeature"]),
    .library(name: "RevealFeature", targets: ["RevealFeature"]),
    .library(name: "SchoolSettingFeature", targets: ["SchoolSettingFeature"]),
    .library(name: "ShareScreenshotFeature", targets: ["ShareScreenshotFeature"]),
    .library(name: "ShopFeature", targets: ["ShopFeature"]),
    .library(name: "TutorialFeature", targets: ["TutorialFeature"]),
  ],
  dependencies: [
    .package(path: "../CupertinoPackage"),
    .package(path: "../UIComponentPackage"),
    .package(path: "../DependencyPackage"),
    .package(url: "https://github.com/airbnb/lottie-spm", from: "4.3.4"),
    .package(url: "https://github.com/edonv/SwiftUIMessage", from: "0.0.3"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.5.0"),
    .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", from: "2.1.1"),
  ],
  targets: [
    .target(name: "AboutFeature", dependencies: [
      "EmailFeature",
      "HowItWorksFeature",
      "DeleteAccountFeature",
      .product(name: "Build", package: "CupertinoPackage"),
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "SwiftUIMessage", package: "SwiftUIMessage"),
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
    ]),
    .target(name: "ActivatedGodModeFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ActivityFeature", dependencies: [
      "ProfileExternalFeature",
    ]),
    .target(name: "AddFeature", dependencies: [
      "FriendRequestFeature",
      "ProfileExternalFeature",
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "SocialShare", package: "UIComponentPackage"),
      .product(name: "SearchField", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "ContactsClient", package: "CupertinoPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ShareLinkClient", package: "DependencyPackage"),
      .product(name: "ShareLinkBuilder", package: "DependencyPackage"),
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
      .product(name: "UIApplicationClient", package: "CupertinoPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AllowAccessFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ContactsClient", package: "CupertinoPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "UserNotificationClient", package: "CupertinoPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AppFeature", dependencies: [
      "LaunchFeature",
      "OnboardFeature",
      "NavigationFeature",
      "ForceUpdateFeature",
      "MaintenanceFeature",
      .product(name: "TcaHelpers", package: "DependencyPackage"),
      .product(name: "StoreKitClient", package: "CupertinoPackage"),
      .product(name: "FacebookClient", package: "DependencyPackage"),
      .product(name: "FirestoreClient", package: "DependencyPackage"),
      .product(name: "UserSettingsClient", package: "DependencyPackage"),
      .product(name: "FirebaseCoreClient", package: "DependencyPackage"),
      .product(name: "FirebaseMessagingClient", package: "DependencyPackage"),
    ]),
    .target(name: "CashOutFeature", dependencies: [
      .product(name: "Lottie", package: "lottie-spm"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "FeedbackGeneratorClient", package: "CupertinoPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ], resources: [.copy("Coin.json")]),
    .target(name: "CupertinoMessageFeature", dependencies: [
      .product(name: "SwiftUIMessage", package: "SwiftUIMessage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "DeleteAccountFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "FirebaseAuthClient", package: "DependencyPackage"),
      .product(name: "DeleteAccountReasonClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "EmailFeature", dependencies: [
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "FindFriendFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ContactsClient", package: "CupertinoPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "FindLocationFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ForceUpdateFeature", dependencies: [
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "FriendRequestFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "BackgroundClearSheet", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GodFeature", dependencies: [
      "PollFeature",
      "CashOutFeature",
      "PlayAgainFeature",
      .product(name: "UserNotificationClient", package: "CupertinoPackage"),
    ], resources: [.copy("Loading.json")]),
    .target(name: "GodModeFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "StoreKitClient", package: "CupertinoPackage"),
      .product(name: "StoreKitHelpers", package: "DependencyPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GradeSettingFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "RoundedCorner", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "HowItWorksFeature", dependencies: [
      .product(name: "Lottie", package: "lottie-spm"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ], resources: [.copy("Onboarding.json")]),
    .target(name: "InAppWebFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "InboxDetailFeature", dependencies: [
      "RevealFeature",
      "GodModeFeature",
      "InboxStoryFeature",
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "UserDefaultsClient", package: "CupertinoPackage"),
      .product(name: "UIApplicationClient", package: "CupertinoPackage"),
      .product(name: "UserNotificationClient", package: "CupertinoPackage"),
      .product(name: "FeedbackGeneratorClient", package: "CupertinoPackage"),
      .product(name: "NotificationCenterClient", package: "CupertinoPackage"),
      .product(name: "AnimationDisableTransaction", package: "UIComponentPackage"),
    ]),
    .target(name: "InboxFeature", dependencies: [
      "InboxDetailFeature",
      "ActivatedGodModeFeature",
    ]),
    .target(name: "InboxStoryFeature", dependencies: [
      .product(name: "God", package: "DependencyPackage"),
      .product(name: "NameImage", package: "UIComponentPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
    ]),
    .target(name: "InviteFriendFeature", dependencies: [
      .product(name: "Lottie", package: "lottie-spm"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ActivityView", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "RoundedCorner", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ShareLinkClient", package: "DependencyPackage"),
      .product(name: "ShareLinkBuilder", package: "DependencyPackage"),
    ], resources: [.copy("Invited.json")]),
    .target(name: "LaunchFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "MaintenanceFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ManageAccountFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "NavigationFeature", dependencies: [
      "AddFeature",
      "GodFeature",
      "InboxFeature",
      "AboutFeature",
      "ProfileFeature",
      "ActivityFeature",
      "TutorialFeature",
    ]),
    .target(name: "OnboardFeature", dependencies: [
      "FindFriendFeature",
      "ProfileStoryFeature",
      "InviteFriendFeature",
      "GradeSettingFeature",
      "SchoolSettingFeature",
      "CupertinoMessageFeature",
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "PhotosClient", package: "CupertinoPackage"),
      .product(name: "SocialShare", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "ActivityView", package: "UIComponentPackage"),
      .product(name: "StringHelpers", package: "DependencyPackage"),
      .product(name: "ShareLinkClient", package: "DependencyPackage"),
      .product(name: "ShareLinkBuilder", package: "DependencyPackage"),
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
      .product(name: "UserDefaultsClient", package: "CupertinoPackage"),
      .product(name: "UIApplicationClient", package: "CupertinoPackage"),
      .product(name: "FirebaseAuthClient", package: "DependencyPackage"),
      .product(name: "UserNotificationClient", package: "CupertinoPackage"),
      .product(name: "FirebaseStorageClient", package: "DependencyPackage"),
      .product(name: "PhoneNumberDependencies", package: "DependencyPackage"),
      .product(name: "FirebaseDynamicLinkClient", package: "DependencyPackage"),
    ], resources: [.copy("onboarding.json")]),
    .target(name: "PlayAgainFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ShareLinkClient", package: "DependencyPackage"),
      .product(name: "ShareLinkBuilder", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "PollFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "FeedbackGeneratorClient", package: "CupertinoPackage"),
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ProfileEditFeature", dependencies: [
      "GradeSettingFeature",
      "ManageAccountFeature",
      "DeleteAccountFeature",
      "SchoolSettingFeature",
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "StringHelpers", package: "DependencyPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "UserDefaultsClient", package: "CupertinoPackage"),
      .product(name: "FirebaseStorageClient", package: "DependencyPackage"),
    ]),
    .target(name: "ProfileExternalFeature", dependencies: [
      "ProfileSharedFeature",
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
    ]),
    .target(name: "ProfileFeature", dependencies: [
      "ShopFeature",
      "ProfileEditFeature",
      "ProfileShareFeature",
      "ProfileExternalFeature",
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
    ]),
    .target(name: "ProfileSharedFeature", dependencies: [
      .product(name: "God", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
    ]),
    .target(name: "ProfileShareFeature", dependencies: [
      "ProfileStoryFeature",
      "CupertinoMessageFeature",
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ShareLinkClient", package: "DependencyPackage"),
      .product(name: "ShareLinkBuilder", package: "DependencyPackage"),
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
      .product(name: "UIApplicationClient", package: "CupertinoPackage"),
      .product(name: "BackgroundClearSheet", package: "UIComponentPackage"),
      .product(name: "AnimationDisableTransaction", package: "UIComponentPackage"),
    ]),
    .target(name: "ProfileStoryFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "RevealFeature", dependencies: [
      .product(name: "Build", package: "CupertinoPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "StoreKitClient", package: "CupertinoPackage"),
      .product(name: "StoreKitHelpers", package: "DependencyPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "SchoolSettingFeature", dependencies: [
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "RoundedCorner", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShareScreenshotFeature", dependencies: [
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "PhotosClient", package: "CupertinoPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShopFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "TutorialFeature", dependencies: [
      .product(name: "Styleguide", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
