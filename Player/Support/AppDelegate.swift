//
//  AppDelegate.swift
//  player
//
//  Created by Cameron Bothner on 1/14/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var radio: WCBNRadioBrain? = nil

  var tipJar = TipJar.sharedInstance

  fileprivate let defaults = UserDefaults.standard

  internal var streamURL: String {
    get {
      if let url = defaults.object(forKey: UserDefaultsKeys.Settings.streamURL) as? String {
        return url
      } else {
        return WCBNStream.URL.medium
      }
    }
    set {
      defaults.set(newValue, forKey: UserDefaultsKeys.Settings.streamURL)
      radio?.stop()
      radio = WCBNRadioBrain()
      radio?.isPlaying = true
    }
  }

  internal var songSearchService: SongSearchService {
    get {
      let name = defaults.string(forKey: UserDefaultsKeys.Settings.songService)
      let svc = SongSearchServiceChoice(rawValue: name ?? "iTunes")
      return getSongSearchService(byChoice: svc ?? .iTunes)
    }
    set {
      defaults.set(newValue.name, forKey: UserDefaultsKeys.Settings.songService)
      NotificationCenter.default
        .post(name: Notification.Name(rawValue: "songSearchServiceChoiceSet"), object: nil)
    }
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    radio = WCBNRadioBrain()

    if let tbc = window?.rootViewController as? UITabBarController {
      tbc.selectedIndex = 2
    }

    UITabBar.appearance().tintColor = UIColor.white
    UITabBar.appearance().alpha = 1.0
    return true
  }
  
  // Handle Spotify OAuth callback
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    let auth = SPTAuth.defaultInstance()
    if (auth?.canHandle(url))! {
      auth?.handleAuthCallback(withTriggeredAuthURL: url) { error, session in
        guard (error == nil)  else {
          print("Auth error: \(error!)")
          return
        }

        auth?.session = session
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SpotifySessionUpdated"), object: self)
      }
      return true
    }
    return false
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    guard let tbc = window?.rootViewController as? UITabBarController else { return }
    if let radioVC = tbc.selectedViewController as? RadioViewController {
      radioVC.closeRadialMenu()
    }
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    guard let tbc = window?.rootViewController as? UITabBarController else { return }
    if let radioVC = tbc.selectedViewController as? RadioViewController {
      radioVC.updateUI()
    }
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

