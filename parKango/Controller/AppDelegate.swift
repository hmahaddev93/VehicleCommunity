//
//  AppDelegate.swift

//
//  Created by Khatib H. on 3/6/19.
//  //

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    let sharedManager:Singleton = Singleton.sharedInstance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Messaging.messaging().shouldEstablishDirectChannel = true
        Messaging.messaging().delegate = self
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.onUpdateFCMToken(notification:)), name: NSNotification.Name(rawValue: "FCMTokenUpdate"), object: nil)


        self.setNavAndTabBarAppearance()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
          Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        // Print full message.
        print(userInfo)
        
        if let notiType = userInfo["gcm.notification.msg_type"] as? String {
            if notiType == PKNotificationType.deleteChat {
                let strMsg = ((userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)["body"] as! String
                let dataDict:[String: String] = ["msg": strMsg]

                NotificationCenter.default.post(name: Notification.Name("PKChatDeleted"), object: nil, userInfo: dataDict)
            }
        }
        
    }
    
    // MARK: - MessagingDelegate Methods
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        self.sharedManager.fcmToken = fcmToken
        
        if ((Auth.auth().currentUser?.uid) != nil) {
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child(Auth.auth().currentUser!.uid).child("fcm_token").setValue(self.sharedManager.fcmToken)
        }
        //let dataDict:[String: String] = ["token": fcmToken]
        //NotificationCenter.default.post(name: Notification.Name("FCMTokenUpdate"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(messaging)
        print(remoteMessage)
    }
    
    
    // MARK: - Event Handlers
    

    // MARK: - Own Methods
    func setNavAndTabBarAppearance (){
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.barStyle = UIBarStyle.black
        navigationBarAppearance.barTintColor = ColorPalette.pkGreen
        navigationBarAppearance.tintColor = UIColor.white
        
        UITabBar.appearance().barTintColor = ColorPalette.pkGreen
        UITabBar.appearance().tintColor = ColorPalette.pkRed
        
    }

}

