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
              song: Song(fromPlist: e["song"]!),
              episode: Episode(fromPlist: e["episode"]!)
            )
          )
        }
        return songs
      } else {
        return []
      }
    }

    set {
      let arr: [[String:AnyObject]] = newValue.map{ e in
        return [ "song": e.song.dictionary, "episode": e.episode.dictionary]
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