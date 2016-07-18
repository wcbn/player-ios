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
  let url: NSURL?

  init(song s: Song, episode ep: Episode, url u: NSURL?) {
    song = s
    episode = ep
    url = u
  }

  init(playlist p: WCBNRadioBrain.Playlist) {
    song = p.song
    episode = p.episode
//    url = p.albumURL
    url = nil
  }
}


@warn_unused_result func == (lhs: Favourite, rhs: Favourite) -> Bool {
  return (lhs.song.timestamp == rhs.song.timestamp)
}