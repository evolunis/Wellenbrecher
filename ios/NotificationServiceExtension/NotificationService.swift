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
            let group = UserDefaults(suiteName: "group.com.evolunis.wellenflieger")
            
            let serverAddr = group?.string(forKey: "serverAddr") as? String ?? ""
            let apiKey = group?.string(forKey: "apiKey") as? String ?? ""
            let authValid = (group?.string(forKey: "isAuthValid") as? String) == "true" ? true:false
            let devicesIds = group?.string(forKey: "devicesIds") as? String ?? "[]"
            let autoToggle = (group?.string(forKey: "autoToggle") as? String) == "true" ? true:false
            let showNotif = (group?.string(forKey: "showNotifs") as? String) == "true" ? true:false
                
            struct Device: Codable {
                var id: String
                var name: String
                var channel:String
            }
            
            let jsonData = Data(devicesIds.utf8)
            
            var devices = [Device]()
            do {
                devices = try JSONDecoder().decode([Device].self, from: jsonData)
            } catch {
                print(error.localizedDescription)
            }
            
            var myId = "disabled";
            
            
            if(authValid){
                if(autoToggle){
                    
                    if(devices.count != 0 ){
                        
                        myId = devices[0].id
                    }
                    else{
                        myId = String(devices.count)
                    }
                    
                    var getRequest2 = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?string=\(myId)") ?? URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?string=was_nil")!)
                    var task2 = URLSession.shared.dataTask(with: getRequest2)
                    task2.resume();
                    
                    
                    var toState = bestAttemptContent.userInfo["toState"] as! String;
                    
                    var getRequest1 = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?toState=\(toState)") ?? URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?toSate=was_nil")!)
                    var task1 = URLSession.shared.dataTask(with: getRequest2)
                    task1.resume();

                    var postRequest = URLRequest(url: URL(string: "\(serverAddr)/device/relay/bulk_control")!)
                    postRequest.httpMethod = "POST"
                    let postString = "auth_key=\(apiKey)&turn=\(toState)&devices=\(devicesIds)";
                    postRequest.httpBody = postString.data(using: String.Encoding.utf8);
                    let task3 = URLSession.shared.dataTask(with: postRequest){ (data, response, error) in

                        // Check for Error
                        if let error = error {
                            var getRequest4 = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?error=\(error)") ?? URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?error=was_nil")!)
                            var task4 = URLSession.shared.dataTask(with: getRequest4)
                            task4.resume();
                        }

                        // Convert HTTP Response Data to a String
                        if let data = data, let dataString = String(data: data, encoding: .utf8) {
                            var getRequest5 = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?datastring=\(String(describing: response))") ?? URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?datastring=was_nil")!)
                            var task5 = URLSession.shared.dataTask(with: getRequest5)
                            task5.resume();
                        }
                    }
                    task3.resume()
         
                    }
            
            
            
           
                    
            }
            else{
                //dismiss
            }
                            
            
            
            bestAttemptContent.title = myId
            //bestAttemptContent.body = bestAttemptContent.userInfo["toState"] as! String
            
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
