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
  
  private let settings: [String: [SettingsGroup]] = [
    "Settings": [
      SettingsGroup(settings: [
        Setting(message: "Stream Quality", accessoryType: .DisclosureIndicator),
        Setting(message: "“Save Song” Service", accessoryType: .DisclosureIndicator)
        ]),
      SettingsGroup(settings: [
        Setting(key: "call", message: "Call the studio"),
        Setting(key: "text", message: "Send an iMessage to the DJ"),
        Setting(key: "Give to WCBN", message: "Give WCBN a buck or two"),
        ]),
      SettingsGroup(settings: [
        Setting(message: "About WCBN"),
        Setting(key: "review", message: "Write a review of our app")
        ])
    ],
    "Stream Quality": [
      SettingsGroup(instructions: "Choose a stream quality.", settings: [
        Setting(key: WCBNStream.URL.high, message: WCBNStream.nameFromURL[WCBNStream.URL.high]!),
        Setting(key: WCBNStream.URL.medium, message: WCBNStream.nameFromURL[WCBNStream.URL.medium]!),
        Setting(key: WCBNStream.URL.low, message: WCBNStream.nameFromURL[WCBNStream.URL.low]!),
        ])
    ],
    "“Save Song” Service": [SettingsGroup(instructions: "Choose which service you’d like to use to save any new favorites you hear on WCBN. You can choose to purchase songs from the iTunes music library, or add them to a Spotify playlist. You can only save songs that are in the library of your chosen service.", settings:
      SongSearchServiceChoice.allChoices.map { choice in
        return Setting(message: choice.rawValue)
      })
    ],
    "Give to WCBN": [
      SettingsGroup(instructions: "Thank you for considering supporting WCBN. Gifts listed above are one-time “In-App Purchases” which support the station.", settings: [
        Setting(key: "1USD", message: "This song is pretty good.", description: "$0.99"),
        Setting(key: "2USD", message: "Wow, this DJ has such personality!", description: "$1.99"),
        Setting(key: "5USD", message: "Can I implant a receiver in my brain yet?", description: "$4.99"),
        ]),
      SettingsGroup(instructions: "You may give any amount, and claim the donation as tax-exempt, by donating through the University of Michigan’s giving portal.", settings: [
        Setting(key: "UM OUD", message: "Make a tax-exempt gift of any amount"),
        ])
    ],
    "About WCBN": [
      SettingsGroup(title: "Freeing your mind since 1972", instructions: "Earliest history of WCBN.\n"),
      SettingsGroup(title: "Personal Radio", instructions: "WCBN DJs always make their own choices.\n"),
    ],
  ]

  @IBOutlet weak var navTitle: UINavigationItem!

  let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

  private struct Storyboard {
    static let CellReuseIdentifier = "Setting"
  }

  private struct SettingsGroup {
    let title: String?
    let instructions: String?
    let settings: [Setting]
    init(title: String? = nil, instructions: String? = nil, settings: [Setting] = []) {
      self.title = title
      self.instructions = instructions
      self.settings = settings
    }
  }

  private struct Setting {
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var key: String
    var message: String
    var realAccessoryType: UITableViewCellAccessoryType
    var description: String?
    var accessoryType: UITableViewCellAccessoryType {
      get {
        if (realAccessoryType == .None) && (
            (key == delegate.streamURL) ||
            (key == delegate.songSearchService.name)
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

    init(key: String, message: String, accessoryType: UITableViewCellAccessoryType = .None, description: String? = nil) {
      self.key = key
      self.message = message
      self.realAccessoryType = accessoryType
      self.description = description
    }

    init(message: String, accessoryType: UITableViewCellAccessoryType = .None) {
      self.init(key: message, message: message, accessoryType: accessoryType)
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

    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionFooterHeight = 100;
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return settings[settingsGroup]!.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settings[settingsGroup]![section].settings.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath)

    let setting = settings[settingsGroup]![indexPath.section].settings[indexPath.row]

    // Configure the cell...
    cell.textLabel?.text = setting.message

    let detail: String
    if let description = setting.description { detail = description }
    else {
      switch setting.key {
      case "Stream Quality":
        detail = WCBNStream.nameFromURL[delegate.streamURL]!
      case "“Save Song” Service":
        detail = delegate.songSearchService.name
      default:
        detail = ""
      }
    }
    cell.detailTextLabel?.text = detail

    cell.accessoryType = setting.accessoryType

    return cell
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return settings[settingsGroup]![section].title
  }

  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let label = labelForFooter(section)
    let v = UIView()
    v.preservesSuperviewLayoutMargins = true
    v.addSubview(label)

    label.topAnchor.constraintEqualToAnchor(v.topAnchor, constant: 8).active = true
    label.bottomAnchor.constraintEqualToAnchor(v.bottomAnchor, constant: 4).active = true

    let guide = v.readableContentGuide
    label.translatesAutoresizingMaskIntoConstraints = false
    guide.leftAnchor.constraintEqualToAnchor(label.leftAnchor).active = true
    guide.rightAnchor.constraintEqualToAnchor(label.rightAnchor).active = true

    return v
  }

  func labelForFooter(section: Int) -> UILabel {
    let label = UILabel()
    label.text = settings[settingsGroup]![section].instructions
    label.font = UIFont(name: "Lato-Regular", size: 15)
    label.numberOfLines = 0
    label.preservesSuperviewLayoutMargins = true
    label.sizeToFit()
    return label
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let action = settings[settingsGroup]![indexPath.section].settings[indexPath.row]

    switch action.key {

    case "call": callWCBN()
    case "text": textWCBN()
    case WCBNStream.URL.high,
         WCBNStream.URL.medium,
         WCBNStream.URL.low:
      delegate.streamURL = action.key
      navigationController?.popViewControllerAnimated(true)

    case let value where SongSearchServiceChoice.rawValues.contains(value):
      let choice = SongSearchServiceChoice(rawValue: action.key)
      let svc = getSongSearchService(byChoice: choice ?? .iTunes)
      delegate.songSearchService = svc
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