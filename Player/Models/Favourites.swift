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

  fileprivate let defaults = UserDefaults.standard

  var songs: [Favourite] {

    get {
      if let plist = defaults.object(forKey: defaultsKey) as? [[String:AnyObject]] {
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
        return [ "song": e.song.dictionary as AnyObject, "episode": e.episode.dictionary as AnyObject]
      }
      defaults.set(arr, forKey: defaultsKey)
    }
  }

  subscript(index: Int) -> Favourite {
    get {
      return songs[songs.count - 1 - index]
    }
  }

  func needsInstructions() -> Bool {
    switch defaults.object(forKey: defaultsKey) {
    case .none:
      return true
    case .some:
      return false
    }
  }

  func removeAtIndex(_ index: Int) {
    songs.remove(at: songs.count - 1 - index)
  }

  var count: Int {
    return songs.count
  }

  func append(_ song: Favourite) {
    songs.append(song)
  }

  func appendCurrentSong(_ p: WCBNRadioBrain.Playlist) {
    append(Favourite(playlist: p))
  }

  func deleteLast() {
    songs.removeLast()
  }

  func isLast(_ s: Favourite) -> Bool {
    return (count > 0) && (songs.last! == s)
  }

  func includeCurrentSong(_ p: WCBNRadioBrain.Playlist) -> Bool {
    return isLast(Favourite(playlist: p))
  }
}
