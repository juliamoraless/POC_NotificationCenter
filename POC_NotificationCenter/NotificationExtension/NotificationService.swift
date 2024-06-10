//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Julia Morales on 04/06/24.
//
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            if let imageURLString = bestAttemptContent.userInfo["imageURL"] as? String, let imageURL = URL(string: imageURLString) {
                downloadAndAttachImage(from: imageURL, to: bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func downloadAndAttachImage(from url: URL, to content: UNMutableNotificationContent) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // Criar um arquivo temporário para a imagem
                let fileManager = FileManager.default
                let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
                let temporaryFolderURL = fileManager.temporaryDirectory.appendingPathComponent(temporaryFolderName)

                do {
                    try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
                    let imageFileURL = temporaryFolderURL.appendingPathComponent("image.jpg")
                    try data.write(to: imageFileURL)

                    // Criar o attachment
                    let attachment = try UNNotificationAttachment(identifier: "image", url: imageFileURL, options: nil)
                    content.attachments = [attachment]
                    self.contentHandler?(content)
                } catch {
                    print("Erro ao salvar a imagem: (error)")
                }
            }
        }
        task.resume()
    }
}

