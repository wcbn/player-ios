//
//  Favourites.swift
//  player
//
//  Created by Cameron Bothner on 1/17/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import Foundation

class Favourites {
  let defaultsKey = "Favourites"

  private let defaults = NSUserDefaults.standardUserDefaults()

  var songs: [Favourite] {
    get {
      if let plist = defaults.objectForKey(defaultsKey) as? [[String:AnyObject]] {
        var songs: [Favourite] = []
        for s in plist {
          let e = s as! [String: [String: AnyObject]]
          songs.append(
            Favourite(
              song: Song(
                artist: e["song"]!["artist"] as! String,
                name: e["song"]!["name"] as! String,
                album: e["song"]!["album"] as! String,
                label: e["song"]!["label"] as! String,
                year: e["song"]!["year"] as? Int,
                request: e["song"]!["request"] as! Bool,
                timestamp: e["song"]!["timestamp"] as? NSDate
              ),
              episode: Episode(
                name: e["episode"]!["name"] as! String,
                dj: e["episode"]!["dj"] as! String,
                beginning: nil,
                ending: nil,
                notes: nil,
                songs: nil
              ),
              url: NSURL(string: e["song"]!["url"] as! String)
            )
          )
        }
        return songs
      } else {
        return []
      }
    }
    set {
      var arr = [[String:AnyObject]]()
      for e in newValue {
        let d: [String: [String: AnyObject]] = [
          "song": [
            "artist": e.song.artist,
            "name": e.song.name,
            "album": e.song.album,
            "label": e.song.label,
            "year": e.song.year ?? 0,
            "request": e.song.request,
            "url": e.url?.absoluteString ?? "",
            "timestamp": e.song.timestamp ?? NSDate() ],
          "episode": [
            "name": e.episode.name,
            "dj": e.episode.dj],
          ]
        arr.append(d)
      }
      defaults.setObject(arr, forKey: defaultsKey)
    }
  }

  subscript(index: Int) -> Favourite {
    get {
      return songs[songs.count - 1 - index]
    }
  }

  func needsInstructions() -> Bool {
    switch defaults.objectForKey(defaultsKey) {
    case .None:
      return true
    case .Some:
      return false
    }
  }

  func removeAtIndex(index: Int) {
    songs.removeAtIndex(songs.count - 1 - index)
  }

  var count: Int {
    return songs.count
  }

  func append(song: Favourite) {
    songs.append(song)
  }

  func appendCurrentSong(p: WCBNRadioBrain.Playlist) {
    append(Favourite(playlist: p))
  }

  func deleteLast() {
    songs.removeLast()
  }

  func isLast(s: Favourite) -> Bool {
    return (count > 0) && (songs.last! == s)
  }

  func includeCurrentSong(p: WCBNRadioBrain.Playlist) -> Bool {
    return isLast(Favourite(playlist: p))
  }
}