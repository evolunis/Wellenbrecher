//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by user226910 on 28.09.22.
//

import UserNotifications
import Foundation

public class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    public override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
           
           //Opening user settings :
            let group = UserDefaults(suiteName: "group.com.evolunis.wellenflieger")
            
            let serverAddr = group?.string(forKey: "serverAddr") as? String ?? ""
            let apiKey = group?.string(forKey: "apiKey") as? String ?? ""
            let authValid = (group?.string(forKey: "isAuthValid") as? String) == "true" ? true:false
            let devices = group?.string(forKey: "devices") as? String ?? "[]"
            let autoToggle = (group?.string(forKey: "autoToggle") as? String) == "true" ? true:false
            let showNotif = (group?.string(forKey: "showNotifs") as? String) == "true" ? true:false
                
            var getRequest = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?string=\(devices)")!)
            let task = URLSession.shared.dataTask(with: getRequest)
            task.resume();
            
            
            if(authValid){
                if(autoToggle){

                    var postRequest = URLRequest(url: URL(string: "\(serverAddr)/device/relay/bulk_control")!)
                    postRequest.httpMethod = "POST"
                    let postString = "userId=300&title=My urgent task&completed=false";
                    postRequest.httpBody = postString.data(using: String.Encoding.utf8);
                    let task = URLSession.shared.dataTask(with: postRequest){ (data, response, error) in
        
        // Check for Error 
        if let error = error {
            print("Error took place \(error)")
        }
 
        // Convert HTTP Response Data to a String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string:\n \(dataString)")
        }
            }
                task.resume()
                }
            }
            else{
                //dismiss
            }
            
            
            bestAttemptContent.title = "Success!"
            bestAttemptContent.body = bestAttemptContent.userInfo["toState"] as! String
            
            contentHandler(bestAttemptContent)
        }
    }
    
    public override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.title = "Timeout!"
            bestAttemptContent.body = "This was too short!"

            contentHandler(bestAttemptContent)
        }
    }

}
