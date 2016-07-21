//
//  SongSearchService.swift
//  player
//
//  Created by Cameron Bothner on 6/27/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import Foundation

protocol SongSearchService {
  var name: String { get }
  var message: String { get }
  var color: String { get }
  
  func lookup(song: Song, then: () -> ())
  func enplaylist(then: () -> ())

  func albumArtURL() -> NSURL?
}

enum SongSearchServiceChoice: String {
  case iTunes
  case Spotify

  static let allChoices = [iTunes, Spotify]
  static var rawValues: [String] { get {
    return allChoices.map { choice in return choice.rawValue }
  }}
}

func getSongSearchService(byChoice choice: SongSearchServiceChoice) -> SongSearchService {
  switch choice {
  case .Spotify:
    return SpotifyService.sharedInstance
  case .iTunes:
    return iTunesService.sharedInstance
  }
}