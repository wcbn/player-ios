//
//  SettingsTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 3/25/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {

  private let settings: [String: [[Setting]]] = [
    "Settings": [
      [
        Setting(message: "Stream Quality", accessoryType: .DisclosureIndicator),
        Setting(message: "“Save Song” Service", accessoryType: .DisclosureIndicator)
      ],[
        Setting(key: "call", message: "Call the studio"),
        Setting(key: "text", message: "Send an iMessage to the DJ"),
        Setting(key: "donate", message: "Give WCBN a buck or two"),
      ],[
        Setting(key: "about", message: "About WCBN"),
        Setting(key: "review", message: "Write a review of our app")
      ]
    ],
    "Stream Quality" : [
      [
        Setting(key: WCBNStream.URL.high, message: WCBNStream.nameFromURL[WCBNStream.URL.high]!),
        Setting(key: WCBNStream.URL.medium, message: WCBNStream.nameFromURL[WCBNStream.URL.medium]!),
        Setting(key: WCBNStream.URL.low, message: WCBNStream.nameFromURL[WCBNStream.URL.low]!),
      ]
    ],
    "“Save Song” Service" : [
      [
        Setting(message: "iTunes"),
        Setting(message: "Spotify"),
        Setting(message: "Apple Music")
      ]
    ]
  ]





  @IBOutlet weak var navTitle: UINavigationItem!

  let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

  private struct Storyboard {
    static let CellReuseIdentifier = "Setting"
  }

  private struct Setting {
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var key: String
    var message: String
    var realAccessoryType: UITableViewCellAccessoryType
    var accessoryType: UITableViewCellAccessoryType {
      get {
        if (realAccessoryType == .None) && (
            (key == delegate.streamURL) //||
//             (key == delegate.saveService)
        ) {
          return .Checkmark
        } else {
          return realAccessoryType
        }
      }
      set {
        realAccessoryType = newValue
      }
    }

    init(key: String, message: String, accessoryType: UITableViewCellAccessoryType) {
      self.key = key
      self.message = message
      self.realAccessoryType = accessoryType
    }

    init(key: String, message: String) {
      self.init(key: key, message: message, accessoryType: .None)
    }

    init(message: String, accessoryType: UITableViewCellAccessoryType) {
      self.init(key: message, message: message, accessoryType: accessoryType)
    }

    init(message: String) {
      self.init(key: message, message: message, accessoryType: .None)
    }
  }

  var settingsGroup = "Settings"

  override func viewDidLoad() {
    super.viewDidLoad()

    let bar = self.navigationController?.navigationBar
    bar?.translucent = false
    bar?.titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Lato-Black", size: 17)!,
      NSForegroundColorAttributeName: UIColor.blackColor()
    ]
    navTitle.title = settingsGroup
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return settings[settingsGroup]!.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settings[settingsGroup]![section].count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath)

    let setting = settings[settingsGroup]![indexPath.section][indexPath.row]

    // Configure the cell...
    cell.textLabel?.text = setting.message

    let detail: String
    switch setting.key {
    case "Stream Quality":
      detail = WCBNStream.nameFromURL[delegate.streamURL]!
//    case "“Save Song” Service":
//      detail = delegate.saveService
    default:
      detail = ""
    }
    cell.detailTextLabel?.text = detail

    cell.accessoryType = setting.accessoryType

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let action = settings[settingsGroup]![indexPath.section][indexPath.row]

    switch action.key {

    case "call": callWCBN()
    case "text": textWCBN()
    case WCBNStream.URL.high,
         WCBNStream.URL.medium,
         WCBNStream.URL.low:
      delegate.streamURL = action.key
      navigationController?.popViewControllerAnimated(true)

    case "iTunes",
         "spotify",
         "appleMusic":
//      delegate.saveService = action.key
      navigationController?.popViewControllerAnimated(true)

    case "review":
      let reviewURL = NSURL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=600658964&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")
      UIApplication.sharedApplication().openURL(reviewURL!)
      deselectSelectedRow()

    default:
      let nextSettingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsTableViewController
      nextSettingsVC.settingsGroup = action.key
      self.navigationController?.pushViewController(nextSettingsVC, animated: true)

    }
  }

}