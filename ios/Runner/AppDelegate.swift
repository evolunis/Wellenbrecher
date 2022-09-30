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

      
    if #available(iOS 10, *) {
          UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ granted, error in }
      } else {
      UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
    }
      UIApplication.shared.registerForRemoteNotifications()

      let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.evolunis.wellenflieger")!
                    .appendingPathComponent("Library/Caches/settings.txt")
    var text = ""
            let fileHandle: FileHandle? = FileHandle(forReadingAtPath: fileURL.path)

if fileHandle != nil {
    // Read data from the file
     Data? data = fileHandle?.readDataToEndOfFile()
   
     // Close the file
     fileHandle?.closeFile()
     // data to string conversion
    text = String(data: data!, encoding: String.Encoding.utf8) as String!
     
}
else {
    text = "Ooops! Something went wrong!"
}

let getRequest2 = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/getKey?dataInDeleg=\(text)")!)
                     let task2 = URLSession.shared.dataTask(with: getRequest2)
                    task2.resume()
     

       


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
/*
  public override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    let deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        
     let getRequest = URLRequest(url: URL(string: "https://us-central1-wellenflieger-ef341.cloudfunctions.net/getKey?key=\(deviceTokenString)")!)
            let task = URLSession.shared.dataTask(with: getRequest)
            task.resume()
}
*/
public override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
}

}


