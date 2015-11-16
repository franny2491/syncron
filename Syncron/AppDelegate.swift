//
//  AppDelegate.swift
//  Syncron
//
//  Created by Armadillo on 07/10/2015.
//  Copyright © 2015 FBeasleySoftware. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        registerNotificationActions()
        
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        let notification :UILocalNotification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 10)
        notification.alertBody = "Notification Fired"
        notification.category = "custom_category_id"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        if notification.category == "custom_category_id" {
            if identifier == "cancel_action_id" {
                print("Cancel was pressed")
            }
            else if identifier == "reply_action_id" {
                print("Reply was pressed")
            }
        }
        
        completionHandler()
    }

    func registerNotificationActions() {
        let cancelAction :UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        cancelAction.identifier = "cancel_action_id"
        cancelAction.title = "Cancel"
        cancelAction.activationMode = UIUserNotificationActivationMode.Background
        cancelAction.destructive = true
        
        let replyAction :UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        replyAction.identifier = "reply_action_id"
        replyAction.title = "Reply"
        replyAction.activationMode = UIUserNotificationActivationMode.Foreground
        replyAction.destructive = false
        
        let category :UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        category.identifier = "custom_category_id"
        category.setActions([cancelAction, replyAction], forContext: UIUserNotificationActionContext.Default)
  
        let categories :NSSet = NSSet(array: [category])
        let settings :UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: (categories as? Set<UIUserNotificationCategory>))
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
}

