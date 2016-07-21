//
//  SpotifyService.swift
//  player
//
//  Created by Cameron Bothner on 7/17/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit

class SpotifyService: SongSearchService {
  static let sharedInstance = SpotifyService()

  var name: String {  get { return "Spotify" }  }
  var message: String {  get { return "Add this song to your Spotify playlist" }  }
  var color: String {  get { return "#1ED760" }  }

  var racing: Bool = false
  var currentSong: Song?
  var currentAlbumArtURL: NSURL?
  var currentAlbumURL: NSURL?

  func lookup(song: Song, then: () -> ()) {
    then()
  }

  func enplaylist(then: () -> ()) {
    then()
  }

  func albumArtURL() -> NSURL? {
    return !racing ? currentAlbumArtURL : nil
  }

}