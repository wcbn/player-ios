//
//  ViewController.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 2015/02/02.
//  Copyright (c) 2015年 Cameron Bothner. All rights reserved.
//

import UIKit
import MediaPlayer

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
  @IBOutlet weak var searchButton: UIButton!

  let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

  let favs = Favourites()
  var resizingLabels: [UILabel] = []

  @IBAction func playOrPauseMusic() {
    delegate.radio!.playOrPause()
    updateUI()
  }
  @IBAction func starSong() {
    delegate.radio!.addToOrRemoveCurrentSongFromFavourites()
    updateUI()
  }
  @IBAction func search() {
    if let url = delegate.radio!.playlist.albumURL {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    notificationCenter.addObserverForName("SongDataReceived",
      object: nil,
      queue: mainQueue)
      { notification in
          self.updateUI()
    }

    self.setNeedsStatusBarAppearanceUpdate()

    playOrPauseMusic()
    self.updateUI()
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
    let song = delegate.radio!.playlist.song
    let show = delegate.radio!.playlist.episode
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
    albumArt.image = delegate.radio!.playlist.albumArt

    // Set color of star button
    starButton.enabled = true
    if favs.includeCurrentSong(delegate.radio!.playlist) {
      starButton.tintColor = Colors.Light.pink
    } else if delegate.radio!.playlist.song.name != "—" {
      starButton.tintColor = UIColor.whiteColor()
    } else {
      starButton.enabled = false
      starButton.tintColor = UIColor.whiteColor()
    }

    // Set contents of play/pause button
    if delegate.radio!.isPlaying {
      playPauseButton.setImage(UIImage(named: "stop"),
                               forState: UIControlState.Normal)
    } else {
      playPauseButton.setImage(UIImage(named: "play"),
                               forState: UIControlState.Normal)
    }

    // Set enabled state of iTunes button
    if let _ = delegate.radio!.playlist.albumURL {
      searchButton.enabled = true
    } else {
      searchButton.enabled = false
    }

  }
  
}