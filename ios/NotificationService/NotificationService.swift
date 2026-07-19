import UserNotifications

class NotificationService: UNNotificationServiceExtension {

  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard let bestAttemptContent else {
      contentHandler(request.content)
      return
    }

    // Download and attach the image if present
    let userInfo = request.content.userInfo
    let imageUrlString =
      (userInfo["imageUrl"] as? String)
      ?? (userInfo["image_url"] as? String)
      ?? ((userInfo["fcm_options"] as? [String: Any])?["image"] as? String)

    guard let urlString = imageUrlString, let url = URL(string: urlString) else {
      contentHandler(bestAttemptContent)
      return
    }

    downloadImage(from: url) { attachment in
      if let attachment {
        bestAttemptContent.attachments = [attachment]
      }
      contentHandler(bestAttemptContent)
    }
  }

  override func serviceExtensionTimeWillExpire() {
    if let contentHandler, let bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

  // MARK: - Private

  private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
    URLSession.shared.downloadTask(with: url) { location, response, _ in
      guard let location else {
        completion(nil)
        return
      }
      // Determine file extension from Content-Type or URL
      let ext = self.fileExtension(for: response, url: url)
      let tmpUrl = location.deletingLastPathComponent().appendingPathComponent(
        UUID().uuidString + ext
      )
      try? FileManager.default.moveItem(at: location, to: tmpUrl)
      let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl, options: nil)
      completion(attachment)
    }.resume()
  }

  private func fileExtension(for response: URLResponse?, url: URL) -> String {
    if let mime = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type") {
      if mime.contains("jpeg") || mime.contains("jpg") { return ".jpg" }
      if mime.contains("png") { return ".png" }
      if mime.contains("gif") { return ".gif" }
      if mime.contains("webp") { return ".webp" }
    }
    let ext = url.pathExtension.lowercased()
    if ["jpg", "jpeg", "png", "gif", "webp"].contains(ext) { return ".\(ext)" }
    return ".jpg"
  }
}
