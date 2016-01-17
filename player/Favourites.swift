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

    var favourites: [Song] {
        get {
            if let plist = defaults.objectForKey(defaultsKey) as? [[String:AnyObject]] {
                var songs = [Song]()
                for s in plist {
                    if let title = s["title"] as? String, artist = s["artist"] as? String, showName = s["show"] as? String, timestamp = s["timestamp"] as? NSDate {
                        let song = Song(title: title,
                            artist: artist,
                            show: showName,
                            timestamp: timestamp)
                        songs.append(song)
                    }
                }
                return songs
            } else {
                return []
            }
        }
        set {
            var arr = [[String:AnyObject]]()
            for song in newValue {
                var d = [String:AnyObject]()
                d["title"] = song.title
                d["artist"] = song.artist
                d["show"] = song.show
                d["timestamp"] = song.timestamp
                arr.append(d)
            }
            defaults.setObject(arr, forKey: defaultsKey)
        }
    }

    func append(song:Song) {
        favourites.insert(song, atIndex: 0)
    }

    func deleteLast() {
        favourites.removeAtIndex(0)
    }
}