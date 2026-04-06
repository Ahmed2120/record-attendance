import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.attendance.record_attendance/notifications",
                                              binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if (call.method == "scheduleAlarms") {
        guard let args = call.arguments as? [String: Any],
              let cinH = args["checkInHour"] as? Int,
              let cinM = args["checkInMinute"] as? Int,
              let coutH = args["checkOutHour"] as? Int,
              let coutM = args["checkOutMinute"] as? Int else {
            result(false)
            return
        }
        self.scheduleAllAlarms(cinH: cinH, cinM: cinM, coutH: coutH, coutM: coutM)
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    registerNotificationCategories()
    UNUserNotificationCenter.current().delegate = self

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func registerNotificationCategories() {
    let checkInAction = UNNotificationAction(identifier: "ACTION_CHECK_IN", title: "Check In", options: [.foreground])
    let checkOutAction = UNNotificationAction(identifier: "ACTION_CHECK_OUT", title: "Check Out", options: [.foreground])

    let category = UNNotificationCategory(identifier: "ATTENDANCE_CATEGORY", 
                                           actions: [checkInAction, checkOutAction], 
                                           intentIdentifiers: [], 
                                           options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])
  }

  private func scheduleAllAlarms(cinH: Int, cinM: Int, coutH: Int, coutM: Int) {
      let center = UNUserNotificationCenter.current()
      center.removeAllPendingNotificationRequests()
      
      scheduleStage(type: "Check-In", hr: cinH, min: cinM, offset: 30)
      scheduleStage(type: "Check-In", hr: cinH, min: cinM, offset: 15)
      scheduleStage(type: "Check-In", hr: cinH, min: cinM, offset: 0)
      
      scheduleStage(type: "Check-Out", hr: coutH, min: coutM, offset: 30)
      scheduleStage(type: "Check-Out", hr: coutH, min: coutM, offset: 15)
      scheduleStage(type: "Check-Out", hr: coutH, min: coutM, offset: 0)
  }

  private func scheduleStage(type: String, hr: Int, min: Int, offset: Int) {
      let content = UNMutableNotificationContent()
      content.title = "\(type) Reminder"
      content.body = offset == 0 ? "It's time for \(type)!" : "\(offset) minutes until \(type)."
      content.categoryIdentifier = "ATTENDANCE_CATEGORY"
      content.sound = .default
      
      var dateComponents = DateComponents()
      dateComponents.hour = hr
      dateComponents.minute = min - offset
      
      // Handle negative minutes
      if dateComponents.minute! < 0 {
          dateComponents.hour! -= 1
          dateComponents.minute! += 60
      }

      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      let request = UNNotificationRequest(identifier: "\(type)_\(offset)", content: content, trigger: trigger)
      
      UNUserNotificationCenter.current().add(request)
  }

  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                      didReceive response: UNNotificationResponse, 
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
      let actionIdentifier = response.actionIdentifier
      let prefs = UserDefaults.standard
      
      if actionIdentifier == "ACTION_CHECK_IN" {
          prefs.set(true, forKey: "flutter.pending_native_check_in")
      } else if actionIdentifier == "ACTION_CHECK_OUT" {
          prefs.set(true, forKey: "flutter.pending_native_check_out")
      }
      prefs.synchronize()
      
      completionHandler()
  }
}
