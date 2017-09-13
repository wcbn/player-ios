//
//  Song.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 3/1/15.
//  Copyright (c) 2015 Cameron Bothner. All rights reserved.
//

import Foundation

struct Favourite {
  let song: Song
  let episode: Episode

  init(song s: Song, episode ep: Episode) {
    song = s
    episode = ep
  }

  init(playlist p: WCBNRadioBrain.Playlist) {
    song = p.song
    episode = p.episode
  }
}


func == (lhs: Favourite, rhs: Favourite) -> Bool {
  return (lhs.song.timestamp == rhs.song.timestamp)
}
