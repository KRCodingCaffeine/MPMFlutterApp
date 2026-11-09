import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Initialize Firebase
          FirebaseApp.configure()

          // Plugins are registered from SceneDelegate after the Flutter view
          // controller exists. UIScene startup creates that controller later
          // than application:didFinishLaunchingWithOptions:.

          // Set the UNUserNotificationCenter delegate
          UNUserNotificationCenter.current().delegate = self
          
          // Request notification permissions
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
          
          application.registerForRemoteNotifications()
          
          return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
