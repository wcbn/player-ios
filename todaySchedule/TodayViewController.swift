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
  @IBOutlet weak var onAirShowName: UILabel!
  @IBOutlet weak var onAirShowWith: UILabel!

  struct TodayViewInfo {
    var showName = ""
    var djName = ""
    var songName: String? = nil
    var artistName: String? = nil

    var songInfo: String {
      get {
        guard let artist = artistName, song = songName else {
          return "No Song"
        }
        return "\(artist): “\(song)”"
      }
    }
    var showWith: String {
      get {
        return "with \(djName)"
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

  func updateUI() {
    onAirSongInfo.text = onAir.songInfo
    onAirShowName.text = onAir.showName
    onAirShowWith.text = onAir.showWith
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    fetchOnAndUpcoming()
    updateUI()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
