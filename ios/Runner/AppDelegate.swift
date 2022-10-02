import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self

      //notification()
    if #available(iOS 10, *) {
          UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ granted, error in }
      } else {
      UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
    }
      UIApplication.shared.registerForRemoteNotifications()
      
      
           
   
    

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


public override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
}

}

func notification(){
    
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
    }
    
    let jsonData = Data(devicesIds.utf8)
    
    var devices = [Device]()
    do {
        devices = try JSONDecoder().decode([Device].self, from: jsonData)
    } catch {
        print(error.localizedDescription)
    }
    
    var myId = "disabled";
    
    
    
    
    var getRequest = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?string=\(myId)") ?? URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/debug?string=was_nil")!)
    var task = URLSession.shared.dataTask(with: getRequest)
    task.resume();
    
    
    
    if(authValid){
        if(autoToggle){
            
            if(devices.count != 0 ){
                
                myId = devices[0].id
            }
            else{
                myId = String(devices.count)
            }
            

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
                    
    }


