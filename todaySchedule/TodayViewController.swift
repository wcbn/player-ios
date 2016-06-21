//
//  TodayViewController.swift
//  todaySchedule
//
//  Created by Cameron Bothner on 6/14/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyJSON

class TodayViewController: UIViewController, NCWidgetProviding {
  @IBOutlet weak var onAirSongInfo: UILabel!
  @IBOutlet weak var onAirShowInfo: UILabel!

  struct TodayViewInfo {
    var showName = ""
    var djName = ""
    var songName: String? = nil
    var artistName: String? = nil

    var songInfo: String {
      get {
        guard let artist = artistName, song = songName else {
          return "—"
        }
        return "\(artist): “\(song)”"
      }
    }
    var showInfo: String {
      get {
        return "\(showName) with \(djName)"
      }
    }
  }

  var onAir = TodayViewInfo() {
    didSet {
      updateUI()
    }
  }

  func fetchOnAndUpcoming() {
    let playlistEndpointURL = NSURL( string: "https://app.wcbn.org/playlist.json")!
    fetch(jsonFrom: playlistEndpointURL) { json in
      let on = json["on_air"]
      let song = on["songs"][0]
      self.onAir = TodayViewInfo(showName: on["name"].stringValue,
                                 djName: on["dj"].stringValue,
                                 songName: song["name"].string,
                                 artistName: song["artist"].string)
    }
  }

  @IBAction func openWCBNApp() {
    let wcbn = NSURL(string: "wcbn://")
    extensionContext?.openURL(wcbn!, completionHandler: nil)
  }

  func updateUI() {
    onAirSongInfo.text = onAir.songInfo
    onAirShowInfo.text = onAir.showInfo
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredContentSize = CGSizeMake(0, 100)
    
    let os = NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0))
    if !os {
      onAirSongInfo.textColor = .whiteColor()
      onAirShowInfo.textColor = .whiteColor()
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    fetchOnAndUpcoming()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(
      top: defaultMarginInsets.top,
      left: defaultMarginInsets.left,
      bottom: defaultMarginInsets.top,
      right: defaultMarginInsets.right)
  }

  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResult.Failed
    // If there's no update required, use NCUpdateResult.NoData
    // If there's an update, use NCUpdateResult.NewData

    fetchOnAndUpcoming()
    completionHandler(NCUpdateResult.NewData)
  }

}
