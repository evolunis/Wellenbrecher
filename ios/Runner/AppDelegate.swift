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
    
    let group = UserDefaults(suiteName: "group.com.evolunis.wellenbrecher")
    
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
            
            var getRequest2 = URLRequest(url: URL(string: "https://us-central1-wellenbrecher-3c570.cloudfunctions.net/debug?string=\(myId)") ?? URL(string: "https://us-central1-wellenbrecher-3c570.cloudfunctions.net/debug?string=was_nil")!)
            var task2 = URLSession.shared.dataTask(with: getRequest2)
            task2.resume();
            
            
            var toState = "on";
            

            var postRequest = URLRequest(url: URL(string: "\(serverAddr)/device/relay/bulk_control")!)
            postRequest.httpMethod = "POST"
            let postString = "auth_key=\(apiKey)&turn=\(toState)&devices=\(devicesIds)";
            postRequest.httpBody = postString.data(using: String.Encoding.utf8);
            let task3 = URLSession.shared.dataTask(with: postRequest){ (data, response, error) in

                // Check for Error
                if let error = error {
                    var getRequest4 = URLRequest(url: URL(string: "https://us-central1-wellenbrecher-3c570.cloudfunctions.net/debug?error=\(error)") ?? URL(string: "https://us-central1-wellenbrecher-3c570.cloudfunctions.net/debug?error=was_nil")!)
                    var task4 = URLSession.shared.dataTask(with: getRequest4)
                    task4.resume();
                }

                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    var getRequest5 = URLRequest(url: URL(string: "https://us-central1-wellenbrecher-3c570.cloudfunctions.net/debug?datastring=\(response)") ?? URL(string: "https://us-central1-wellenbrecher-3c570.cloudfunctions.net/debug?datastring=was_nil")!)
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
                    
    }


