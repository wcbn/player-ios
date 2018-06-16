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

  let delegate = UIApplication.shared.delegate as! AppDelegate

  let favs = Favourites()
  var resizingLabels: [UILabel] = []

  var radialMenu: RadialMenu!

  struct RadialOption {
    var name: String
    var message: String
    var color: String
  }

  var options: [RadialOption] = [
      RadialOption(name: "act-heart", message: "Add this song to your favorites", color: "#F47CC3"),
      RadialOption(name: "act-message", message: "Send an iMessage to the DJ", color: "#2ECC71"),
      RadialOption(name: "", message: "", color: "#000000"),
      RadialOption(name: "act-share", message: "Share this song with your friends", color: "#5B48A2"),
    ]

  @IBAction func playOrPauseMusic(_: UITapGestureRecognizer) {
    let defaults = UserDefaults.standard
    defaults.set(true, forKey: UserDefaultsKeys.launchedBefore)

    delegate.radio!.playOrPause()
    updateUI()
  }
  func starSong() {
    delegate.radio!.addToOrRemoveCurrentSongFromFavourites()
    updateUI()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let notificationCenter = NotificationCenter.default
    let mainQueue = OperationQueue.main
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "SongDataReceived"), object: nil, queue: mainQueue) { _ in
      if (self.delegate.radio?.isPlaying ?? false) {
        self.explainInterface()
      }
      self.updateUI()
    }
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "songSearchServiceChoiceSet"), object: nil, queue: mainQueue) { _ in
      self.loadRadialMenu()
    }


    self.setNeedsStatusBarAppearanceUpdate()

    let defaults = UserDefaults.standard
    if (defaults.bool(forKey: UserDefaultsKeys.launchedBefore)) {
      delegate.radio!.playOrPause()
    }

    self.updateUI()
    
    let l = albumArt.layer
    // White border
    l.borderColor = UIColor.white.cgColor
    l.borderWidth = 2.0
    // Drop shadow
    l.shadowPath = UIBezierPath(rect: l.bounds).cgPath
    l.shadowColor = UIColor.black.cgColor
    l.shadowOpacity = 0.5
    l.shadowOffset = CGSize(width: 0, height: 16)
    l.shadowRadius = 40

    loadRadialMenu()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateUI()
  }

  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }

  func stringOrDash(_ s : String) -> String {
    if s == "" {
      return "—"
    } else {
      return s
    }
  }

  let albumArtEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  let blurBehindRadialMenu = UIVisualEffectView(effect: UIBlurEffect(style: .light))
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
      l.shadowPath = UIBezierPath(rect: l.bounds).cgPath
      l.shadowColor = UIColor.black.cgColor

      UIView.transition(with: albumArt, duration: 0.2, options: .transitionCrossDissolve,
                                animations: { self.albumArtEffectView.removeFromSuperview() },
                                completion: nil)
      UIView.transition(with: playButton, duration: 0.2, options: .transitionCrossDissolve,
                                animations: { self.playButton.isHidden = true },
                                completion: nil)
    } else {
      l.borderWidth = 0
      l.shadowColor = UIColor.white.cgColor

      albumArtEffectView.frame = l.bounds
      UIView.transition(with: albumArt, duration: 0.2, options: .transitionCrossDissolve,
                                animations: { self.albumArt.addSubview(self.albumArtEffectView) },
                                completion: nil)
      UIView.transition(with: playButton, duration: 0.2, options: .transitionCrossDissolve,
                                animations: { self.playButton.isHidden = false },
                                completion: nil)
    }
  }

  func updateUI() {
    updateLabels()
    delay(0.01) {
      self.updateUIReflectingPlayOrPause()
    }
  }


  var explainedThisSession = false

  func explainInterface() {
    if explainedThisSession {  return  }
    let defaults = UserDefaults.standard

    if (!defaults.bool(forKey: UserDefaultsKeys.ExplainedInterface.radialMenu)) {
      explainRadialMenu()
    }

    explainedThisSession = true
  }
}
