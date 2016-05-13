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
    var albumURL: NSURL? = nil

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

    radio.play()
  }

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "timedMetadata"  { fetchSongInfo() }
  }

  // MARK: - Networking

  private func fetchSongInfo() {
    let background_qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(background_qos, 0)) {
      let playlist_api_url = NSURL( string: "http://app.wcbn.org/playlist.json")!
      if let data = NSData(contentsOfURL: playlist_api_url) {
        dispatch_async(dispatch_get_main_queue()) {
          let json = JSON(data: data)

          self.playlist.semesterID = json["on_air"]["semester_id"].int

          var songs: [Song] = []
          for (_, s) : (String, JSON) in json["on_air"]["songs"] {
            let song = Song(
             artist:   s["artist"].stringValue,
             name:     s["name"].stringValue,
             album:    s["album"].stringValue,
             label:    s["label"].stringValue,
             year:     s["year"].int,
             request:  s["request"].boolValue,
             timestamp:s["at"].dateTime
            )
            songs.append(song)
          }

          let episode = Episode(
            name:  json["on_air"]["name"].stringValue,
            dj:    json["on_air"]["dj"].stringValue,
            beginning: json["on_air"]["beginning"].dateTime,
            ending: json["on_air"]["ending"].dateTime,
            notes: json["on_air"]["show_notes"].string,
            songs: songs
          )
//          let episodeChanged = episode.beginning != self.playlist.episode.beginning
          let episodeChanged = true
          self.playlist.episode = episode

          if episodeChanged { self.fetchSchedule() }
          self.fetchAlbumArt()
        }
      }
    }
  }


  private func fetchSchedule() {
    let background_qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(background_qos, 0)) {
      if let semester_id = self.playlist.semesterID {
        let playlist_api_url = NSURL( string: "http://app.wcbn.org/semesters/\(semester_id).json")!
        if let data = NSData(contentsOfURL: playlist_api_url) {
          dispatch_async(dispatch_get_main_queue()) {
            let json = JSON(data: data)

            var weekdays: [Weekday] = []
            for (weekday, shows) : (String, JSON) in json["shows"] {
              let w = Int(weekday)!
              var ss: [Show] = []
              for (i, show) : (String, JSON) in shows {
                var djs: [Show.DJ] = []
                for (_, dj) : (String, JSON) in show["djs"] {
                  djs.append(Show.DJ(name: dj["name"].stringValue, path: dj["url"].stringValue))
                }

                let s = Show()
                s.url_for = show["url"].stringValue
                s.name = show["name"].stringValue
                s.description = show["description"].stringValue
                s.djs = djs
                s.with = show["with"].stringValue
                s.start = show["beginning"].dateTime!
                s.end = show["ending"].dateTime!
                s.onAir = show["on_air"].boolValue
                s.episodes = nil

                if (s.onAir) {
                  let iP = NSIndexPath(forRow: Int(i)!, inSection: w - 1)
                  self.playlist.showOnAir = iP
                }
                ss.append(s)
              }
              ss.sortInPlace { a, b in  a.start.compare(b.start) == NSComparisonResult.OrderedAscending}
              weekdays.append(Weekday(index: w, name: WCBNRadioBrain.Weekdays[w], shows: ss))
            }
            self.playlist.schedule = weekdays.sort { a, b in return a.index < b.index }
            NSNotificationCenter.defaultCenter()
              .postNotificationName("PlaylistDataReceived", object: nil)
          }
        }
      }
    }
  }

  func fetchAlbumArt() {
    playlist.albumArt = defaultAlbum
    playlist.albumURL = nil

    if playlist.song.timestamp == nil { return }

    let background_qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(background_qos, 0)) {
      let artist = self.playlist.song.artist
      let album = self.playlist.song.album
      let raw_query: String
      if album.lowercaseString.rangeOfString("single") != nil || album.isEmpty {
        raw_query = "\(artist) \(self.playlist.song.name)"
      } else {
        raw_query = "\(artist) \(album)"
      }
      if let query = raw_query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
        let iTunesQueryURL = "https://itunes.apple.com/search?limit=1&version=2&entity=album&term=\(query)"
        let apiURL = NSURL(string: iTunesQueryURL)!
        if let data = NSData(contentsOfURL: apiURL) {
          dispatch_async(dispatch_get_main_queue()) {
            let json = JSON(data: data)
            let results = json["results"]
            if results.count > 0 {
              let smallArtworkURL = results[0]["artworkUrl100"].stringValue

              let regex = try! NSRegularExpression(pattern: "100x100", options: .CaseInsensitive)
              let bigArtworkURL = regex.stringByReplacingMatchesInString(smallArtworkURL, options: [], range: NSRange(0..<smallArtworkURL.utf16.count), withTemplate: "1000x1000")
              self.albumArtURL = NSURL(string: bigArtworkURL)

              self.playlist.albumURL = NSURL(string: results[0]["collectionViewUrl"].stringValue)
              print("iTunes API: artworkUrl = \(self.albumArtURL), collectionViewUrl = \(self.playlist.albumURL)")
            }
          }
        }
      }
    }
  }

  private func fetchImage() {
    if let url = albumArtURL {
      let qos = Int(QOS_CLASS_BACKGROUND.rawValue)
      dispatch_async(dispatch_get_global_queue(qos, 0)) {
        let imageData = NSData(contentsOfURL: url)
        if url == self.albumArtURL {
          dispatch_async(dispatch_get_main_queue()) {
            if imageData != nil {
              self.playlist.albumArt = UIImage(data: imageData!)
            } else {
              self.playlist.albumArt = self.defaultAlbum
            }
            NSNotificationCenter.defaultCenter()
              .postNotificationName("SongDataReceived", object: nil)
            self.playlist.setNowPlayingInfo()
          }
        }
      }
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