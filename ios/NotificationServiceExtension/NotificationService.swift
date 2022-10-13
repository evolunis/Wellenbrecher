import UserNotifications
import Foundation

public class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    public override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let group = UserDefaults(suiteName: "group.com.evolunis.wellenbrecher")
            
            let serverAddr = group?.string(forKey: "serverAddr") as? String ?? ""
            let apiKey = group?.string(forKey: "apiKey") as? String ?? ""
            let authValid = (group?.string(forKey: "isAuthValid") as? String) == "true" ? true:false
            let devicesIds = group?.string(forKey: "devicesIds") as? String ?? "[]"
            let autoToggle = (group?.string(forKey: "autoToggle") as? String) == "false" ? false:true
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
            
            
            
            if(authValid){
                if(autoToggle){
                    
                    var toState = bestAttemptContent.userInfo["toState"] as! String;
                    

                    var postRequest = URLRequest(url: URL(string: "\(serverAddr)/device/relay/bulk_control")!)
                    postRequest.httpMethod = "POST"
                    let postString = "auth_key=\(apiKey)&turn=\(toState)&devices=\(devicesIds)";
                    postRequest.httpBody = postString.data(using: String.Encoding.utf8);
                    let task = URLSession.shared.dataTask(with: postRequest){ (data, response, error) in

                        // Check for Error
                        if let error = error {
                
                        }

                        // Convert HTTP Response Data to a String
                        if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        
                        }
                    }

                    task.resume()
                    bestAttemptContent.title = "Energy market has changed :"
                    bestAttemptContent.body = "Your devices were turned \(bestAttemptContent.userInfo["toState"] as! String) !"
                
         
                    }
                else{
                    bestAttemptContent.title = "Energy market has changed :"
                    bestAttemptContent.body = "Time to turn your devices \(bestAttemptContent.userInfo["toState"] as! String) !"
                }
        }
            
            else{
                //Dismiss notification
            }
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
