//
//  ViewController.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 2015/02/02.
//  Copyright (c) 2015年 Cameron Bothner. All rights reserved.
//

import UIKit
import MediaPlayer

class RadioViewController: UIViewController, UIGestureRecognizerDelegate {
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

  @IBAction func playOrPauseMusic(_: UITapGestureRecognizer) {
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

  let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))

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
                                animations: { self.effectView.removeFromSuperview() },
                                completion: nil)
      UIView.transitionWithView(playButton, duration: 0.2, options: .TransitionCrossDissolve,
                                animations: { self.playButton.hidden = true },
                                completion: nil)
    } else {
      l.borderWidth = 0
      l.shadowColor = UIColor.whiteColor().CGColor

      effectView.frame = l.bounds
      UIView.transitionWithView(albumArt, duration: 0.2, options: .TransitionCrossDissolve,
                                animations: { self.albumArt.addSubview(self.effectView) },
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