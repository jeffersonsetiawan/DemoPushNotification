//
//  AppDelegate.swift
//  PushNotification
//
//  Created by Jefferson Setiawan on 13/09/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import UserNotifications
import UIKit

public enum NotificationCategoryIdentifier {
    static let news = "CATEGORY_NEWS"
}

public enum NotificationActionIdentifier {
    static let newsView = "ACTION_VIEW_NEWS"
    static let newsComment = "ACTION_NEWS_COMMENT"
    static let newsViewed = "ACTION_VIEWED_NEWS"
    static let reactionAction = "ACTION_REACTION"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupRootPage()
        registerForPushNotifications()
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject],
            let aps = notification["aps"] as? [String: AnyObject] {
            print("aps: \(aps)")
            let vc = PushVC(title: "Push From App launch")
            UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func setupRootPage() {
        window = UIWindow()
        let rootVc = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = rootVc
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("JEFF userInfo: \(userInfo)")
        let vc = PushVC(title: "Push From Active background")
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
        completionHandler(.newData)
    }
    
    func registerForPushNotifications() {
        setupNotificationCategory()
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func setupNotificationCategory() {
        let summaryFormat = "Ada %u notif lagi dari %@."
        let hiddenPreviewsPlaceholder = "%u notifikasi baru"
        let viewAction = UNNotificationAction(
          identifier: NotificationActionIdentifier.newsView,
          title: "View",
          options: [.foreground]
        )
        
        let commentAction = UNTextInputNotificationAction(
          identifier: NotificationActionIdentifier.newsComment,
          title: "Comment",
          options: [.foreground],
          textInputButtonTitle: "Post",
          textInputPlaceholder: "Komentar"
        )
        
        let reactionAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.reactionAction,
            title: "Reaction",
            options: []
        )

        let newsCategory = UNNotificationCategory(
          identifier: NotificationCategoryIdentifier.news,
          actions: [viewAction, commentAction, reactionAction],
          intentIdentifiers: [],
          hiddenPreviewsBodyPlaceholder: hiddenPreviewsPlaceholder,
          categorySummaryFormat: summaryFormat,
          options: [.hiddenPreviewsShowTitle]
        )

        // 3
        UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let title: String
        switch response.actionIdentifier {
        case NotificationActionIdentifier.newsView:
            title = "View Action Tap"
        case NotificationActionIdentifier.newsComment:
            if let textResponse = response as? UNTextInputNotificationResponse {
                title = textResponse.userText
            } else {
                title = "Empty input"
            }
        default:
            title = "Push from in app state"
        }
        let vc = PushVC(title: title)
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
        
        completionHandler()
    }
}

extension UIApplication {
    public class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let search = base as? UISearchController {
            return search.presentingViewController
        }
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
