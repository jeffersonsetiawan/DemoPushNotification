//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Jefferson Setiawan on 18/09/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var imageVIew: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = "\(notification.request.content.body) | update from content"
        
        guard let attachmentUrl = notification.request.content.attachments.first?.url else {
            return
        }
        
        if attachmentUrl.startAccessingSecurityScopedResource() {
            imageVIew.image = UIImage(data: NSData(contentsOfFile: attachmentUrl.path)! as Data)
            attachmentUrl.stopAccessingSecurityScopedResource()
        }
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "ACTION_VIEW_NEWS" {
            let viewedAction = UNNotificationAction(identifier: "ACTION_VIEWED_NEWS", title: "VIEWED", options: [])
            var newActions = extensionContext?.notificationActions ?? []
            newActions[0] = viewedAction
            extensionContext?.notificationActions = newActions
            self.label?.text = "VIEWED"
            completion(.doNotDismiss)
        }
        else if response.actionIdentifier == "ACTION_VIEWED_NEWS" {
            let viewAction = UNNotificationAction(identifier: "ACTION_VIEW_NEWS", title: "VIEW", options: [])
            var newActions = extensionContext?.notificationActions ?? []
            newActions[0] = viewAction
            extensionContext?.notificationActions = newActions
            self.label?.text = "VIEW"
            completion(.doNotDismiss)
        }
        else if response.actionIdentifier == "ACTION_NEWS_COMMENT" {
            if let textResponse = response as? UNTextInputNotificationResponse {
                self.label?.text = textResponse.userText
            }
            completion(.doNotDismiss)
        }
        else if response.actionIdentifier == "ACTION_REACTION" {
            self.becomeFirstResponder()
        }
        else {
            completion(.dismissAndForwardAction)
        }
    }
}
