//
//  ViewController.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 2015/02/02.
//  Copyright (c) 2015年 Cameron Bothner. All rights reserved.
//

import UIKit

class RadioViewController: UIViewController {
  @IBOutlet weak var showTitle: UILabel!
  @IBOutlet weak var showDescription: UILabel!
  @IBOutlet weak var songTitle: UILabel!
  @IBOutlet weak var songArtist: UILabel!
  @IBOutlet weak var songAlbum: UILabel!
  @IBOutlet weak var songLabel: UILabel!
  @IBOutlet weak var songYear: UILabel!
  @IBOutlet weak var albumArt: UIImageView! {
    didSet {
      albumArt.layer.borderColor = UIColor.whiteColor().CGColor
      albumArt.layer.borderWidth = 2.0
    }
  }
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var starButton: UIButton! {
    didSet { starButton.tintColor = UIColor.whiteColor() }
  }
  
  let radio = WCBNRadioBrain()
  let favs = Favourites()
  var resizingLabels: [UILabel] = []
  
  
  @IBAction func playOrPauseMusic() {
    radio.playOrPause()
    flipPlayPause()
  }
  @IBAction func starSong() {
    if starButton.tintColor == UIColor.whiteColor() {
      starButton.tintColor = UIColor(hue: 48.0 / 360, saturation: 0.99, brightness: 1.0, alpha: 1.0)
      let song = Song(
        title: radio.currentInfo.song.name,
        artist: radio.currentInfo.song.artist,
        show: radio.currentInfo.show.name,
        timestamp: NSDate())
      favs.append(song)
      
    } else {
      starButton.tintColor = UIColor.whiteColor()
      favs.deleteLast()
    }
  }
  @IBAction func search() {
    if let url = radio.currentInfo.song.albumURL{
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    notificationCenter.addObserverForName("DataReceived",
      object: nil,
      queue: mainQueue)
      { notification in
          self.updateUI()
    }

    self.setNeedsStatusBarAppearanceUpdate()

    playOrPauseMusic()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateUI()
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }

  func stringOrDash(s : String) -> String {
    if s == "" {
      return "—"
    } else {
      return s
    }
  }
  
  func updateUI() {
    let song = radio.currentInfo.song
    let show = radio.currentInfo.show
    showTitle.text = show.name
    if show.dj == "" {
      showDescription.text = "—"
    } else {
      showDescription.text = "with \(show.dj)"
    }
    songTitle.text = stringOrDash(song.name)
    songArtist.text = stringOrDash(song.artist)
    songAlbum.text = stringOrDash(song.album)
    songLabel.text = stringOrDash(song.label)
    if song.year != nil {
      songYear.text = "\(song.year!)"
    } else {
      songYear.text = "—"
    }
    albumArt.image = song.albumArt
    
//    autoNumberOfLines(showTitle, maxLines: 2)
//    resizingLabels = [showDescription, songTitle, songArtist, songAlbum, songLabel, songYear]
//    for label in resizingLabels {
//      autoNumberOfLines(label, maxLines: 3)
//    }

  }

  func flipPlayPause() {
    if radio.isPlaying {
      playPauseButton.setImage(UIImage(named: "stop"),
        forState: UIControlState.Normal)
    } else {
      playPauseButton.setImage(UIImage(named: "play"),
        forState: UIControlState.Normal)
    }
  }
  
  func currentInfoChanged(object: NSNotification!) {
  }
  
  func autoNumberOfLines(label: UILabel, maxLines: Int) {
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    label.numberOfLines = maxLines
    label.sizeToFit()
  }
  
}