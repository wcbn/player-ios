//
//  ViewController.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 2015/02/02.
//  Copyright (c) 2015年 Cameron Bothner. All rights reserved.
//

import UIKit
import MediaPlayer
import MessageUI

class RadioViewController: UIViewController,
UIGestureRecognizerDelegate,
MFMessageComposeViewControllerDelegate
{
  @IBOutlet weak var showTitle: UILabel!
  @IBOutlet weak var showDescription: UILabel!
  @IBOutlet weak var songTitle: UILabel!
  @IBOutlet weak var songArtist: UILabel!
  @IBOutlet weak var songAlbum: UILabel!
  @IBOutlet weak var songLabelAndYear: UILabel!
  @IBOutlet weak var albumArt: UIImageView!
  @IBOutlet weak var playButton: UIImageView!

  let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

  let favs = Favourites()
  var resizingLabels: [UILabel] = []

  var radialMenu: RadialMenu!

  struct RadialOption {
    var name: String
    var message: String
    var color: String
  }

  let options: [RadialOption] = [
    RadialOption(name: "act-heart", message: "Add this song to your favorites", color: "#F47CC3"),
    RadialOption(name: "act-message", message: "Send an iMessage to the DJ", color: "#2ECC71"),
    RadialOption(name: "act-iTunes", message: "Find this song in the iTunes Store", color: "#FFCD01"),
    RadialOption(name: "act-share", message: "Share this song with your friends", color: "#5B48A2"),
  ]

  func playOrPauseMusic(_: UITapGestureRecognizer) {
    delegate.radio!.playOrPause()
    updateUI()
  }
  func starSong() {
    delegate.radio!.addToOrRemoveCurrentSongFromFavourites()
    updateUI()
  }
  func searchiTunes() {
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

    delegate.radio!.playOrPause()
    self.updateUI()
    
    let l = albumArt.layer
    // White border
    l.borderColor = UIColor.whiteColor().CGColor
    l.borderWidth = 2.0
    // Drop shadow
    l.shadowPath = UIBezierPath(rect: l.bounds).CGPath
    l.shadowColor = UIColor.blackColor().CGColor
    l.shadowOpacity = 0.5
    l.shadowOffset = CGSizeMake(0, 16)
    l.shadowRadius = 40

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playOrPauseMusic))
    tapRecognizer.delegate = self
    self.albumArt.addGestureRecognizer(tapRecognizer)
    self.albumArt.userInteractionEnabled = true

    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(openRadialMenu(_:)))
    albumArt.addGestureRecognizer(longPress)

    loadRadialMenu()
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

  let albumArtEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
  let blurBehindRadialMenu = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
  let radialMenuHint = UILabel()

  func updateLabels() {
    let song = delegate.radio!.currentSong
    let show = delegate.radio!.currentEpisode
    showTitle.text = stringOrDash(show.name)
    if show.dj == "" {
      showDescription.text = "—"
    } else {
      showDescription.text = "with \(show.dj)"
    }
    songTitle.text = stringOrDash(song.name)
    songArtist.text = stringOrDash(song.artist)
    songAlbum.text = stringOrDash(song.album)
    var labelAndYear = stringOrDash(song.label)
    if song.year != nil {
      labelAndYear += " (\(song.year!))"
    }
    songLabelAndYear.text = labelAndYear
    albumArt.image = delegate.radio!.playlist.albumArt
  }

  func updateUIReflectingPlayOrPause() {
    let l = albumArt.layer
    if delegate.radio!.isPlaying {
      l.borderWidth = 2.0
      l.shadowPath = UIBezierPath(rect: l.bounds).CGPath
      l.shadowColor = UIColor.blackColor().CGColor

      UIView.transitionWithView(albumArt, duration: 0.2, options: .TransitionCrossDissolve,
                                animations: { self.albumArtEffectView.removeFromSuperview() },
                                completion: nil)
      UIView.transitionWithView(playButton, duration: 0.2, options: .TransitionCrossDissolve,
                                animations: { self.playButton.hidden = true },
                                completion: nil)
    } else {
      l.borderWidth = 0
      l.shadowColor = UIColor.whiteColor().CGColor

      albumArtEffectView.frame = l.bounds
      UIView.transitionWithView(albumArt, duration: 0.2, options: .TransitionCrossDissolve,
                                animations: { self.albumArt.addSubview(self.albumArtEffectView) },
                                completion: nil)
      UIView.transitionWithView(playButton, duration: 0.2, options: .TransitionCrossDissolve,
                                animations: { self.playButton.hidden = false },
                                completion: nil)
    }
  }

  func updateUI() {
    updateLabels()
    updateUIReflectingPlayOrPause()

//    // Set color of star button
//    starButton.enabled = true
//    if favs.includeCurrentSong(delegate.radio!.playlist) {
//      starButton.tintColor = Colors.Light.pink
//    } else if delegate.radio!.playlist.song.name != "—" {
//      starButton.tintColor = UIColor.whiteColor()
//    } else {
//      starButton.enabled = false
//      starButton.tintColor = UIColor.whiteColor()
//    }

//    // Set enabled state of iTunes button
//    if let _ = delegate.radio!.playlist.albumURL {
//      searchButton.enabled = true
//    } else {
//      searchButton.enabled = false
//    }

  }
}