//
//  WCBNRadioBrain.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 2015/02/02.
//  Copyright (c) 2015年 Cameron Bothner. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import MediaPlayer
import UIKit
import SwiftyJSON

class WCBNRadioBrain: NSObject{

  // MARK: - Data Structures & Constants
  static let Weekdays = ["", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  struct Weekday {
    var index: Int
    var name:  String
    var shows: [Show]
  }

  class Playlist {
    var episode = Episode() {
      didSet { setNowPlayingInfo() }
    }

    var semesterID: Int? = nil

    var albumArt = UIImage(named: "AlbumDefault")

    var song: Song {
      get {
        if let s = episode.songs?.first { return s }
        else { return Song() }
      }
    }
    var schedule: [Weekday] = []
    var showOnAir: NSIndexPath? = nil

    var titleForMPNowPlayingInfoCenter: String {
      get {
        if song.name != "—" { return song.name }
        else if episode.name != "" { return episode.unambiguousName }
        else { return "WCBN-FM Ann Arbor" }
      }
    }
    var artistForMPNowPlayingInfoCenter: String {
      get {
        if song.artist != "—" { return song.artist }
        else { return "" }
      }
    }
    var albumTitleForMPNowPlayingInfoCenter: String {
      get {
        let t = titleForMPNowPlayingInfoCenter
        if t == song.name {
          return "WCBN-FM: \(episode.name) with \(episode.dj)"
        } else {
          return "WCBN-FM"
        }
      }
    }

    var description: String {
      get {
        var d = ""
        if song.name != "—" { d += "\(song.name) " }
        if song.name != "—" && song.artist != "—" { d += "by " }
        if song.artist != "—" { d += "\(song.artist) " }
        if song.name != "—" || song.artist != "—" { d += "on "}
        d += "\(episode.unambiguousName)"
        return d
      }
    }

    func setNowPlayingInfo() {
      NSNotificationCenter.defaultCenter().postNotificationName("SongDataReceived", object: nil)
      
      MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
        MPMediaItemPropertyTitle: titleForMPNowPlayingInfoCenter,
        MPMediaItemPropertyArtist: artistForMPNowPlayingInfoCenter,
        MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: albumArt!),
        MPMediaItemPropertyAlbumTitle: albumTitleForMPNowPlayingInfoCenter,
        MPNowPlayingInfoPropertyPlaybackRate: NSNumber(float: 1.0)
      ]
    }
  }

  // MARK: - Instance Variables
  let delegate = UIApplication.sharedApplication().delegate as? AppDelegate

  var playerItem: AVPlayerItem
  var radio: AVPlayer
  var backgroundTaskIdentifier = UIBackgroundTaskInvalid
  var isPlaying = false
  let favourites = Favourites()

  var optionalDescription: String? {
    get {
      if !isPlaying { return nil }
      return playlist.description
    }
  }

  let defaultAlbum = UIImage(named: "AlbumDefault")!

  var playlist = Playlist()

  var albumArtURL: NSURL? {
    didSet {
      fetchImage()
    }
  }

  var currentSong: Song {
    get {
      if isPlaying { return playlist.song }
      return Song()
    }
  }

  var currentEpisode: Episode {
    get {
      if isPlaying { return playlist.episode }
      return Episode()
    }
  }

  var currentAlbumArt: UIImage {
    get {
      if isPlaying { return playlist.albumArt! }
      return defaultAlbum
    }
  }

  // MARK: - Lifecycle

  override init() {
    let streamURL: String
    if let preferredStreamURL = delegate?.streamURL {
      streamURL = preferredStreamURL
    } else {
      streamURL = WCBNStream.URL.medium
    }
    playerItem = AVPlayerItem(URL: NSURL(string: streamURL)!)
    radio = AVPlayer(playerItem: playerItem)

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryPlayback)
    } catch {}

    super.init()

    playerItem.addObserver(self, forKeyPath: "timedMetadata", options: .Old, context: nil)

    UIApplication.sharedApplication().beginReceivingRemoteControlEvents()

    let remoteCC = MPRemoteCommandCenter.sharedCommandCenter()
    remoteCC.pauseCommand.addTargetWithHandler{ _ in self.stop() }
    remoteCC.playCommand.addTargetWithHandler{ _ in self.play() }
    remoteCC.nextTrackCommand.enabled = false
    remoteCC.previousTrackCommand.enabled = false

    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    notificationCenter.addObserverForName("SpotifySessionUpdated", object: nil, queue: mainQueue) { _ in
      self.fetchSongInfo()
    }
    notificationCenter.addObserverForName("songSearchServiceChoiceSet", object: nil, queue: mainQueue) { _ in
      self.fetchAlbumArtURL()
    }
  }

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "timedMetadata"  { fetchSongInfo() }
  }

  // MARK: - Networking

  private func fetchSongInfo() {
    let playlistEndpointURL = NSURL( string: "https://app.wcbn.org/playlist.json")!
    fetch(jsonFrom: playlistEndpointURL) { json in
      self.playlist.semesterID = json["on_air"]["semester_id"].int
      
      let episode = Episode(fromJSON: json["on_air"])
      let episodeChanged = episode.beginning != self.playlist.episode.beginning
      self.playlist.episode = episode

      if episodeChanged { self.fetchSchedule() }

      self.fetchAlbumArtURL()
    }
  }

  private func fetchAlbumArtURL() {
      self.delegate!.songSearchService.lookup(self.playlist.song) {
        self.albumArtURL = self.delegate!.songSearchService.albumArtURL
      }
  }


  private func fetchSchedule() {
    guard let semesterID = self.playlist.semesterID else { return }
    let semesterEndpointURL = NSURL( string: "https://app.wcbn.org/semesters/\(semesterID).json")!

    fetch(jsonFrom: semesterEndpointURL) { json in
      var weekdays: [Weekday] = []
      for (weekday, shows) : (String, JSON) in json["shows"] {
        let w = Int(weekday)!
        var ss: [Show] = []
        for (i, show) : (String, JSON) in shows {
          let s = Show(fromJSON: show)
          if (s.onAir) {
            let iP = NSIndexPath(forRow: Int(i)!, inSection: w - 1)
            self.playlist.showOnAir = iP
          }
          ss.append(s)
        }
        ss.sortInPlace { a, b in  a.start.compare(b.start) == .OrderedAscending}
        weekdays.append(Weekday(index: w, name: WCBNRadioBrain.Weekdays[w], shows: ss))
      }
      self.playlist.schedule = weekdays.sort { a, b in return a.index < b.index }
      NSNotificationCenter.defaultCenter()
        .postNotificationName("PlaylistDataReceived", object: nil)
    }
  }

  private func fetchImage() {
    guard let url = albumArtURL else {
      playlist.albumArt = defaultAlbum
      return
    }
    fetch(dataFrom: url, onFailure: { self.playlist.albumArt = self.defaultAlbum })
    { imageData in
      self.playlist.albumArt = UIImage(data: imageData)
      NSNotificationCenter.defaultCenter()
        .postNotificationName("SongDataReceived", object: nil)
      self.playlist.setNowPlayingInfo()
    }
  }

  // MARK: - Actions

  func play() -> MPRemoteCommandHandlerStatus {
    isPlaying = true
    radio.replaceCurrentItemWithPlayerItem(playerItem)
    radio.play()
    return .Success
  }

  func stop() -> MPRemoteCommandHandlerStatus {
    isPlaying = false
    radio.pause()
    playlist.albumArt = self.defaultAlbum
    radio.replaceCurrentItemWithPlayerItem(nil)
    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
      MPMediaItemPropertyTitle: "WCBN-FM Ann Arbor",
      MPMediaItemPropertyArtist: "",
      MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: self.defaultAlbum),
      MPMediaItemPropertyAlbumTitle: "",
      MPNowPlayingInfoPropertyPlaybackRate: NSNumber(float: 0.0)
    ]
    return .Success
  }

  func playOrPause() {
    if isPlaying {
      stop()
    } else {
      play()
    }
  }

  func addToOrRemoveCurrentSongFromFavourites() -> MPRemoteCommandHandlerStatus {
    if (favourites.includeCurrentSong(playlist)) {
      favourites.deleteLast()
    } else {
      favourites.appendCurrentSong(playlist)
    }
    return .Success
  }

  deinit {
    playerItem.removeObserver(self, forKeyPath: "timedMetadata")
  }
}