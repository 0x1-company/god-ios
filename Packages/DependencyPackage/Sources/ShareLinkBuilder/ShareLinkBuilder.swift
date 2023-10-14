import Foundation

public func buildShareText(
  path: GodAppJpPath,
  username: String?,
  source: UtmSource? = nil,
  medium: UtmMedium? = nil
) -> String? {
  guard let username else { return nil }
  let link = buildGodLink(path: path, username: username, source: source, medium: medium)
  return String(
    localized: "Try downloading the new app!\n\(link.absoluteString)",
    bundle: .module
  )
}

public func buildForLine(
  path: GodAppJpPath,
  username: String?,
  source: UtmSource? = nil,
  medium: UtmMedium? = nil
) -> URL? {
  guard
    let username,
    let shareText = buildShareText(path: path, username: username, source: source, medium: medium),
    let text = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
  else { return nil }

  return URL(string: "https://line.me/R/share?text=\(text)")
}

public func buildGodLink(
  path: GodAppJpPath,
  username: String,
  source: UtmSource? = nil,
  medium: UtmMedium? = nil
) -> URL {
  var components = URLComponents(string: "https://godapp.jp")!
  components.path = "/\(path.rawValue)/\(username)"
  var queryItems: [URLQueryItem] = []
  if let source {
    queryItems.append(URLQueryItem(name: "utm_source", value: source.rawValue))
  }
  if let medium {
    queryItems.append(URLQueryItem(name: "utm_medium", value: medium.rawValue))
  }
  if !queryItems.isEmpty {
    components.queryItems = queryItems
  }
  return components.url!
}
