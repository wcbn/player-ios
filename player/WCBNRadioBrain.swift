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
    var showOnAir: IndexPath? = nil

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
      NotificationCenter.default.post(name: Notification.Name(rawValue: "SongDataReceived"), object: nil)
      
      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
        MPMediaItemPropertyTitle: titleForMPNowPlayingInfoCenter,
        MPMediaItemPropertyArtist: artistForMPNowPlayingInfoCenter,
        MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: albumArt!),
        MPMediaItemPropertyAlbumTitle: albumTitleForMPNowPlayingInfoCenter,
        MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0 as Float)
      ]
    }
  }

  // MARK: - Instance Variables
  let delegate = UIApplication.shared.delegate as? AppDelegate

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

  var albumArtURL: URL? {
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
    playerItem = AVPlayerItem(url: URL(string: streamURL)!)
    radio = AVPlayer(playerItem: playerItem)

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryPlayback)
    } catch {}

    super.init()

    playerItem.addObserver(self, forKeyPath: "timedMetadata", options: .old, context: nil)

    UIApplication.shared.beginReceivingRemoteControlEvents()

    let remoteCC = MPRemoteCommandCenter.shared()
    remoteCC.pauseCommand.addTarget(handler: { _ in self.stop() })
    remoteCC.playCommand.addTarget(handler: { _ in self.play() })
    remoteCC.nextTrackCommand.isEnabled = false
    remoteCC.previousTrackCommand.isEnabled = false

    let notificationCenter = NotificationCenter.default
    let mainQueue = OperationQueue.main
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "SpotifySessionUpdated"), object: nil, queue: mainQueue) { _ in
      self.fetchSongInfo()
    }
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "songSearchServiceChoiceSet"), object: nil, queue: mainQueue) { _ in
      self.fetchAlbumArtURL()
    }

    self.fetchSongInfo()
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "timedMetadata"  { fetchSongInfo() }
  }

  // MARK: - Networking

  fileprivate func fetchSongInfo() {
    let playlistEndpointURL = URL( string: "https://app.wcbn.org/playlist.json")!
    fetch(jsonFrom: playlistEndpointURL) { json in
      self.playlist.semesterID = json["on_air"]["semester_id"].int
      
      let episode = Episode(fromJSON: json["on_air"])
      let episodeChanged = episode.beginning != self.playlist.episode.beginning
      self.playlist.episode = episode

      if episodeChanged { self.fetchSchedule() }

      self.fetchAlbumArtURL()
    }
  }

  fileprivate func fetchAlbumArtURL() {
      self.delegate!.songSearchService.lookup(self.playlist.song) {
        self.albumArtURL = self.delegate!.songSearchService.albumArtURL
      }
  }


  fileprivate func fetchSchedule() {
    guard let semesterID = self.playlist.semesterID else { return }
    let semesterEndpointURL = URL( string: "https://app.wcbn.org/semesters/\(semesterID).json")!

    fetch(jsonFrom: semesterEndpointURL) { json in
      var weekdays: [Weekday] = []
      for (weekday, shows) : (String, JSON) in json["shows"] {
        let w = Int(weekday)!
        var ss: [Show] = []
        for (i, show) : (String, JSON) in shows {
          let s = Show(fromJSON: show)
          if (s.onAir) {
            let iP = IndexPath(row: Int(i)!, section: w - 1)
            self.playlist.showOnAir = iP
          }
          ss.append(s)
        }
        ss.sort { a, b in  a.start.compare(b.start) == .orderedAscending}
        weekdays.append(Weekday(index: w, name: WCBNRadioBrain.Weekdays[w], shows: ss))
      }
      self.playlist.schedule = weekdays.sorted { a, b in return a.index < b.index }
      NotificationCenter.default.post(name: Notification.Name("PlaylistDataReceived"), object: nil)
    }
  }

  fileprivate func fetchImage() {
    guard let url = albumArtURL else {
      playlist.albumArt = defaultAlbum
      self.playlist.setNowPlayingInfo()
      return
    }
    fetch(dataFrom: url, onFailure: {
      self.playlist.albumArt = self.defaultAlbum
      self.playlist.setNowPlayingInfo()
      })
    { imageData in
      self.playlist.albumArt = UIImage(data: imageData)
      NotificationCenter.default
        .post(name: Notification.Name(rawValue: "SongDataReceived"), object: nil)
      self.playlist.setNowPlayingInfo()
    }
  }

  // MARK: - Actions

  func play() -> MPRemoteCommandHandlerStatus {
    isPlaying = true
    radio.replaceCurrentItem(with: playerItem)
    radio.play()
    return .success
  }

  func stop() -> MPRemoteCommandHandlerStatus {
    isPlaying = false
    radio.pause()
    playlist.albumArt = self.defaultAlbum
    radio.replaceCurrentItem(with: nil)
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
      MPMediaItemPropertyTitle: "WCBN-FM Ann Arbor",
      MPMediaItemPropertyArtist: "",
      MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: self.defaultAlbum),
      MPMediaItemPropertyAlbumTitle: "",
      MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 0.0 as Float)
    ]
    return .success
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
    return .success
  }

  deinit {
    playerItem.removeObserver(self, forKeyPath: "timedMetadata")
  }
}
