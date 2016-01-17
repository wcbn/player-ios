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

class WCBNRadioBrain: NSObject{

  struct currentInfoType {
    var title = "[Song]"
    var artist = "[Artist]"
    var showTitle = "[Show Name]"
    var albumArt = UIImage(named: "AlbumDefault")
    var searchURL = NSURL(string: "http://www.wcbn.org")
  }

  struct songInfo {
    var artist = "—"
    var name = "—"
    var album = "—"
    var albumArt = UIImage(named: "AlbumDefault")
    var albumURL = NSURL(string: "http://www.wcbn.org")
    var label = "—"
    var year: Int? = nil
    var request = false
  }

  struct showInfo {
    var name = "Loading…"
    var dj = ""
    var times = " "
  }

  struct playlistInfo {
    var song = songInfo()
    var show = showInfo()
  }

  var playerItem: AVPlayerItem
  var radio: AVPlayer
  var isPlaying = false

  let defaultAlbum = UIImage(named: "AlbumDefault")!
  let defaultSearchURL = NSURL(string: "http://www.wcbn.org")

  var currentInfo = playlistInfo() {
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName("DataReceived", object: nil)

      let wcbn_string = "WCBN-FM — \(currentInfo.show.name) with \(currentInfo.show.dj)"
      MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
        MPMediaItemPropertyTitle: currentInfo.song.name,
        MPMediaItemPropertyArtist: currentInfo.song.artist,
        MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: currentInfo.song.albumArt!),
        MPMediaItemPropertyAlbumTitle: wcbn_string
      ]
    }
  }

  var albumArtURL: NSURL? {
    didSet {
      fetchImage()
    }
  }


  override init() {
    let streamHD = NSURL(string: "http://www.wcbn.org/wcbn-hd.m3u" )
    playerItem = AVPlayerItem(URL: streamHD!)
    radio = AVPlayer(playerItem: playerItem)

    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryPlayback)
    } catch {}

    super.init()

    playerItem.addObserver(self, forKeyPath: "timedMetadata", options: .Old, context: nil)

    radio.rate = 1.0
    radio.play()

    UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
  }

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "timedMetadata"  { fetchSongInfo() }
  }
  
  private func fetchSongInfo() {
    let qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(qos, 0)) {
      let apiURL = NSURL( string: "http://app.wcbn.org/playlist.json" )!
      let data = NSData(contentsOfURL: apiURL)
      dispatch_async(dispatch_get_main_queue()) {
        do {
          let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

          let show = showInfo(
            name:  jsonObject["on_air"]!!["name"] as! String,
            dj:    jsonObject["on_air"]!!["dj"] as! String,
            times: jsonObject["on_air"]!!["times"] as! String
          )
          self.currentInfo.show = show

          let songs = jsonObject["on_air"]!!["songs"] as! [AnyObject]
          if songs.count > 0 {
            let now = songs.first
            let song = songInfo(
              artist:   now!["artist"] as! String,
              name:     now!["name"] as! String,
              album:    now!["album"] as! String,
              albumArt: self.currentInfo.song.albumArt,
              albumURL: self.currentInfo.song.albumURL,
              label:    now!["label"] as! String,
              year:     now!["year"] as? Int,
              request:  now!["request"] as! Bool
            )
            self.currentInfo.song = song
            self.getAlbumArt()
          }
          print(self.currentInfo)

        } catch {}
      }
    }
  }
  
  func getAlbumArt() {
    currentInfo.song.albumArt = defaultAlbum
    currentInfo.song.albumURL = defaultSearchURL

    let qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(qos, 0)) {
      if let album = self.currentInfo.song.album.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
        let iTunesQueryURL = "https://itunes.apple.com/search?limit=1&version=2&entity=album&term=\(album)"
        let apiURL = NSURL(string: iTunesQueryURL)!
        let data = NSData(contentsOfURL: apiURL)
        dispatch_async(dispatch_get_main_queue()) {
          do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            let results = jsonObject["results"] as! [AnyObject]
            if results.count > 0 {
              let result = results.first
              let smallArtworkURL = result!["artworkUrl100"] as! String
              let regex = try! NSRegularExpression(pattern: "100x100", options: .CaseInsensitive)
              
              let bigArtworkURL = regex.stringByReplacingMatchesInString(smallArtworkURL, options: [], range: NSRange(0..<smallArtworkURL.utf16.count), withTemplate: "1000x1000")
              self.albumArtURL = NSURL(string: bigArtworkURL)
              self.currentInfo.song.albumURL = NSURL(string: result!["collectionViewUrl"] as! String)
              print("iTunes API: artworkUrl = \(self.albumArtURL), collectionViewUrl = \(self.currentInfo.song.albumURL)")
            }
          } catch {}
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
              self.currentInfo.song.albumArt = UIImage(data: imageData!)
            } else {
              self.currentInfo.song.albumArt = self.defaultAlbum
            }
            NSNotificationCenter.defaultCenter()
              .postNotificationName("DataReceived", object: nil)
          }
        }
      }
    }
  }

  func playOrPause() {
    if isPlaying {
      print("Radio Paused")
      isPlaying = false
      radio.replaceCurrentItemWithPlayerItem(nil)
    } else {
      print("Radio Playing")
      isPlaying = true
      radio.replaceCurrentItemWithPlayerItem(playerItem)
    }
  }
}