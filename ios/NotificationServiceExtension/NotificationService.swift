//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by user226910 on 28.09.22.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    public override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let getRequest = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/testCalled")!)
            let task = URLSession.shared.dataTask(with: getRequest)
            task.resume()
            bestAttemptContent.title = "modified !"
            
            contentHandler(bestAttemptContent)
        }
    }
    
    public override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
