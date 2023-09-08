import Foundation

public enum Constants {
  public static let appId = "6457261581"
  public static let appStoreURL = URL(string: "https://apps.apple.com/jp/app/id\(Self.appId)")!
  public static let appStoreReviewURL = URL(string: "https://itunes.apple.com/us/app/apple-store/id\(Self.appId)?mt=8&action=write-review")!

  public static let founderURL = URL(string: "https://instagram.com/satoya__")!
  public static let developerURL = URL(string: "https://instagram.com/tomokisun")!

  public static let quickActionURLs: [String: URL] = [
    "talk-to-founder": Self.founderURL,
    "talk-to-developer": Self.developerURL,
  ]

  public static let godappteam = "godappteam"
  public static let xURL = URL(string: "https://twitter.com/\(Self.godappteam)")!
  public static let instagramURL = URL(string: "https://instagram.com/\(Self.godappteam)")!
  public static let tiktokURL = URL(string: "https://tiktok.com/\(Self.godappteam)")!

  public static let docsURL = URL(string: "https://docs.godapp.jp")!
  public static let faqURL = URL(string: "\(Self.docsURL)/faq")!
  public static let safetyCenterURL = URL(string: "\(Self.docsURL)/safety-center")!
  public static let privacyPolicyURL = URL(string: "\(Self.docsURL)/privacy-policy")!
  public static let termsOfUseURL = URL(string: "\(Self.docsURL)/terms-of-use")!
}
