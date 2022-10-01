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
            let authValid = (group?.string(forKey: "authValid") as? String) == "true" ? true:false
            let devicesId = group?.string(forKey: "devicesId") as? String ?? "[]"
            let autoToggle = (group?.string(forKey: "autoToggle") as? String) == "true" ? true:false
            let showNotif = (group?.string(forKey: "showNotif") as? String) == "true" ? true:false

            if(authValid){
                if(autoToggle){

                    let postRequest = URLRequest(url: URL(string: "\(serverAddr)/device/relay/bulk_control")!)
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


            let getRequest = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/getKey?UDresult=\(String(describing: server))")!)
             let task = URLSession.shared.dataTask(with: getRequest)
            task.resume()
            
            
            bestAttemptContent.title = "Success!"
            bestAttemptContent.body = server
            
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
