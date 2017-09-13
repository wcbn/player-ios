//
//  SettingsTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 3/25/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class SettingsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {

  typealias STVC = SettingsTableViewController

  static func conditionalTipJarSetting() -> [Setting] {
    if SKPaymentQueue.canMakePayments() {
      return [Setting(key: "give", message: "Give WCBN a buck or two")]
    } else {
      return []
    }
  }

  static let settings: [String: [SettingsGroup]] = [
    "Settings": [
      SettingsGroup(settings: [
        Setting(message: "Stream Quality", accessoryType: .disclosureIndicator),
        Setting(message: "“Save Song” Service", accessoryType: .disclosureIndicator)
        ]),
      SettingsGroup(settings: [
        Setting(key: "call", message: "Call the studio"),
        Setting(key: "text", message: "Send an iMessage to the DJ")
        ] + STVC.conditionalTipJarSetting()),
      SettingsGroup(settings: [
        Setting(message: "About WCBN"),
        Setting(key: "review", message: "Write a review of our app")
        ])
    ],
    "Stream Quality": [
      SettingsGroup(instructions:
        "Choosing the highest quality stream is essential for your audiophile cred: our HD stream sounds better than our FM broadcast! But the higher the quality, the more buffering you might experience, and the more data you will use. WCBN is not liable for any overage fees you may be charged, but we will be deeply honored to learn of their extent.",
        settings: [
        Setting(key: WCBNStream.URL.high, message: "HD", description: "320 kbps = 144 MB/hr"),
        Setting(key: WCBNStream.URL.medium, message: "Normal", description: "128 kbps = 57.6 MB/hr"),
        Setting(key: WCBNStream.URL.low, message: "Low Quality", description: "64 kbps = 28.8 MB/hr"),
        ]),
    ],
    "“Save Song” Service": [SettingsGroup(instructions: "Choose which service you’d like to use to save any new favorites you hear on WCBN. You can choose to purchase songs from the iTunes music library, or add them to a Spotify playlist. You can only save songs that are in the library of your chosen service.", settings:
      SongSearchServiceChoice.allChoices.map { choice in
        return Setting(message: choice.rawValue)
      })
    ],
    "About WCBN": [
      SettingsGroup(title: "The far left of the dial", instructions:
        "WCBN is the University of Michigan’s student run, freeform radio station, broadcasting all day, everyday, at 88.3MHz in Ann Arbor, MI. We are proud to expose our listeners to music and public affairs shows that they cannot hear on other radio stations. In doing so, we develop the individual voices of our student DJs, and build them up as managers, fundraisers, engineers, technologists, and artists.\n"),
      SettingsGroup(title: "Freeing your mind since 1972", instructions:
        "The Campus Broadcasting Network was born in 1952 as an AM station in three University dormitories and could only be heard in those buildings. To reach a wider audience with our unique student perspective, we moved to FM in 1972. We have grown and shrunk over the years, as the stature of college radio waxed and waned, but in a world where every song  is available at a touch, we have found a niche as curatorial tastemakers to help you cut through the noise.\n"),
      SettingsGroup(title: "Personal Radio", instructions:
        "Foundational to our philosophy of “Freeform” is the idea that every DJ has a right and a responsibility to thoughtfully choose each song that they play. We have no prescriptions for numbers of hits per hour, nor computerized playlist-players to automate a show. Whether music or talk, every moment of every show on WCBN is the pure creative output of its host. Shoot them a note or pick up the phone: make a connection with your DJ.\n\n"),
    ],
  ]

  @IBOutlet weak var navTitle: UINavigationItem!

  let delegate = UIApplication.shared.delegate as! AppDelegate

  fileprivate struct Storyboard {
    static let CellReuseIdentifier = "Setting"
  }

  struct SettingsGroup {
    let title: String?
    let instructions: String?
    let settings: [Setting]
    init(title: String? = nil, instructions: String? = nil, settings: [Setting] = []) {
      self.title = title
      self.instructions = instructions
      self.settings = settings
    }
  }

  struct Setting {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var key: String
    var message: String
    var realAccessoryType: UITableViewCellAccessoryType
    var description: String?
    var accessoryType: UITableViewCellAccessoryType {
      get {
        if (realAccessoryType == .none) && (
            (key == delegate.streamURL) ||
            (key == delegate.songSearchService.name)
        ) {
          return .checkmark
        } else {
          return realAccessoryType
        }
      }
      set {
        realAccessoryType = newValue
      }
    }

    init(key: String, message: String, accessoryType: UITableViewCellAccessoryType = .none, description: String? = nil) {
      self.key = key
      self.message = message
      self.realAccessoryType = accessoryType
      self.description = description
    }

    init(message: String, accessoryType: UITableViewCellAccessoryType = .none) {
      self.init(key: message, message: message, accessoryType: accessoryType)
    }
  }

  var settingsGroup = "Settings"

  override func viewDidLoad() {
    super.viewDidLoad()

    let bar = self.navigationController?.navigationBar
    bar?.isTranslucent = false
    bar?.titleTextAttributes = [
      .font: UIFont(name: "Lato-Black", size: 17)!,
      .foregroundColor: UIColor.black
    ]

    navTitle.title = settingsGroup

    tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionFooterHeight = 1000;

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    view.setNeedsLayout()
  }


  override func numberOfSections(in tableView: UITableView) -> Int {
    return STVC.settings[settingsGroup]!.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return STVC.settings[settingsGroup]![section].settings.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath)

    let setting = STVC.settings[settingsGroup]![indexPath.section].settings[indexPath.row]

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

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return STVC.settings[settingsGroup]![section].title
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let label = labelForFooter(section)
    let v = UIView()
    v.preservesSuperviewLayoutMargins = true
    v.addSubview(label)

    label.topAnchor.constraint(equalTo: v.topAnchor, constant: 8).isActive = true
    label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: 0).isActive = true

    let guide = v.readableContentGuide
    label.translatesAutoresizingMaskIntoConstraints = false
    guide.leftAnchor.constraint(equalTo: label.leftAnchor).isActive = true
    guide.rightAnchor.constraint(equalTo: label.rightAnchor).isActive = true

    return v
  }

  func labelForFooter(_ section: Int) -> UILabel {
    let label = UILabel()
    label.text = STVC.settings[settingsGroup]![section].instructions
    if tableView.numberOfRows(inSection: section) > 0 {
      label.font = UIFont(name: "Lato-Regular", size: 14)
      label.textColor = UIColor.gray
    } else {
      label.font = UIFont(name: "Lato-Regular", size: 16)
    }
    label.allowsDefaultTighteningForTruncation = true
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.9
    label.numberOfLines = 0
    label.preservesSuperviewLayoutMargins = true
    return label
  }
}
