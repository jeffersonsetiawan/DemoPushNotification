//
//  NotificationService.swift
//  NotificationService
//
//  Created by Jefferson Setiawan on 18/09/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent),
            let apnsData = content.userInfo["data"] as? [String: Any],
            let attachmentURLString = apnsData["attachment-url"] as? String,
            let attachmentURL = URL(string: attachmentURLString) else {
            return contentHandler(request.content)
        }
        guard let imageData = NSData(contentsOf: attachmentURL) else {
            return contentHandler(request.content)
        }
        let fileName: String
        if content.categoryIdentifier == "CATEGORY_VIDEO" {
            fileName = "video.mp4"
        } else {
            fileName = "image.png"
        }
        guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: fileName, data: imageData, options: nil) else {
            return contentHandler(request.content)
        }

//        content.summaryArgument = "Haha"
        content.attachments = [attachment]
        contentHandler(content.copy() as! UNNotificationContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}


extension UNNotificationAttachment {
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {

            let fileManager = FileManager.default
            let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
            let fileURLPath      = NSURL(fileURLWithPath: NSTemporaryDirectory())
            let tmpSubFolderURL  = fileURLPath.appendingPathComponent(tmpSubFolderName, isDirectory: true)

            do {
                try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
                let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
                try data.write(to: fileURL!, options: [])
                let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL!, options: options)
                return imageAttachment
            } catch let error {
                print("error \(error)")
            }

        return nil
    }
}
