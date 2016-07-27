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
  var currentAlbumArtURL: NSURL?
  var currentAlbumURL: NSURL?

  init() {
    print("Initializing iTunesService shared instance now.")
  }

  func lookup(song: Song, then: () -> ()) {
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

  func enplaylist(then: () -> ()) {
    guard let url = currentAlbumURL else {  return  }
    UIApplication.sharedApplication().openURL(url)
    then()
  }

  var albumArtURL: NSURL? { get {
    return !racing ? currentAlbumArtURL : nil
  } }



  private func queryiTunes(then: () -> ()) {
    guard let song = currentSong else {  return  }

    fetch(jsonFrom: queryURL(song)) { response in
      let results = response["results"]
      if results.count > 0 {
        self.currentAlbumArtURL = self.largeAlbumArtURL(fromSmallArtworkURL: results[0]["artworkUrl100"].stringValue)
        self.currentAlbumURL = NSURL(string: results[0]["collectionViewUrl"].stringValue)
      }

      then()
    }
  }

  private func queryURL(song: Song) -> NSURL {
    return NSURL(string: "https://itunes.apple.com/search?limit=1&version=2&entity=album&term=\(queryString(song))")!
  }

  private func queryString(song: Song) -> String {
    let rawQuery: String
    if song.album.lowercaseString.rangeOfString("single") != nil || song.album.isEmpty {
      rawQuery = "\(song.artist) \(song.name)"
    } else {
      rawQuery = "\(song.artist) \(song.album)"
    }

    return rawQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
  }

  private func largeAlbumArtURL(fromSmallArtworkURL small: String) -> NSURL? {
    let regex = try! NSRegularExpression(pattern: "100x100", options: .CaseInsensitive)
    let bigArtworkURL = regex.stringByReplacingMatchesInString(small, options: [], range: NSRange(0..<small.utf16.count), withTemplate: "1000x1000")
    return NSURL(string: bigArtworkURL)
  }
}