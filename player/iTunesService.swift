//
//  iTunesService.swift
//  player
//
//  Created by Cameron Bothner on 6/27/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit

class iTunesService : SongSearchService {
  static let sharedInstance = iTunesService()

  var name: String {  get { return "iTunes" }  }
  var message: String {  get { return "Find this song in the iTunes Store" }  }
  var color: String {  get { return "#FFCD01" }  }

  var racing: Bool = false

  var currentSong: Song?
  var currentAlbumArtURL: URL?
  var currentAlbumURL: URL?

  init() {
    print("Initializing iTunesService shared instance now.")
  }

  func lookup(_ song: Song, then: @escaping () -> ()) {
    if currentSong != nil && currentSong! == song {
      then()
    } else {
      currentSong = song
      queryiTunes(then)
    }
  }

  var canEnplaylist: Bool { get {
    return currentAlbumURL != nil
  } }

  func enplaylist(_ then: @escaping () -> ()) {
    guard let url = currentAlbumURL else {  return  }
    UIApplication.shared.openURL(url)
    then()
  }

  var albumArtURL: URL? { get {
    return !racing ? currentAlbumArtURL : nil
  } }



  fileprivate func queryiTunes(_ then: @escaping () -> ()) {
    guard let song = currentSong, !(song.blank) else {
      self.currentAlbumArtURL = nil
      self.currentAlbumURL = nil
      then()
      return
    }

    fetch(jsonFrom: queryURL(song)) { response in
      let results = response["results"]
      if results.count > 0 {
        self.currentAlbumArtURL = self.largeAlbumArtURL(fromSmallArtworkURL: results[0]["artworkUrl100"].stringValue)
        self.currentAlbumURL = URL(string: results[0]["collectionViewUrl"].stringValue)
        print("iTunes: Track found at \(self.currentAlbumURL!)")
      } else {
        self.currentAlbumArtURL = nil
        self.currentAlbumURL = nil
        print("iTunes: Track not found")
      }

      then()
    }
  }

  fileprivate func queryURL(_ song: Song) -> URL {
    return URL(string: "https://itunes.apple.com/search?limit=1&version=2&entity=album&term=\(queryString(song))")!
  }

  fileprivate func queryString(_ song: Song) -> String {
    let rawQuery: String
    if song.album.lowercased().range(of: "single") != nil || song.album.isEmpty {
      rawQuery = "\(song.artist) \(song.name)"
    } else {
      rawQuery = "\(song.artist) \(song.album)"
    }

    return rawQuery.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
  }

  fileprivate func largeAlbumArtURL(fromSmallArtworkURL small: String) -> URL? {
    let regex = try! NSRegularExpression(pattern: "100x100", options: .caseInsensitive)
    let bigArtworkURL = regex.stringByReplacingMatches(in: small, options: [], range: NSRange(0..<small.utf16.count), withTemplate: "1000x1000")
    return URL(string: bigArtworkURL)
  }
}
