//
//  Song.swift
//  player
//
//  Created by Cameron Bothner on 2016/04/10.
//  Copyright © 2016年 Cameron Bothner. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Song : Equatable {
  var artist = "—"
  var name = "—"
  var album = "—"
  var label = "—"
  var year: Int? = nil
  var request = false
  var timestamp: Date? = nil

  var blank: Bool {
    get {
      return self == Song()
    }
  }

  var at : String {
    get {
      if let t = timestamp {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        return dateFormatter.string(from: t)
      }
      else { return "" }
    }
  }
  var longAt: String {
    get {
      if let t = timestamp {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: t)
      } else { return "" }
    }
  }

  var description: String {
    // Song Name by Artist on Album (Label, 2016)
    let nameStr  = name != ""    ?   "“\(name)” by "   : ""
    let albumStr = album != ""   ?   " on \(album)"    : ""
    let needsParens = label != "" || year != 0
    let openParen = needsParens ? " (" : ""
    let closeParen = needsParens ? ")" : ""
    let comma = ((label != "" && year != 0) ? ", " : "" )
    let labelAndYear = openParen + (label != "" ? label : "") + comma + (year != 0 ? "\(year!)" : "") + closeParen
    return nameStr + artist + albumStr + labelAndYear
  }

  init() {  }

  init(fromJSON json: JSON) {
    artist = json["artist"].stringValue
    name = json["name"].stringValue
    album = json["album"].stringValue
    label = json["label"].stringValue
    year = json["year"].int
    request = json["request"].boolValue
    timestamp = json["at"].dateTime
 }
  
  init(fromPlist plist: [String: AnyObject]) {
    artist = plist["artist"] as! String
    name = plist["name"] as! String
    album = plist["album"] as! String
    label = plist["label"] as! String
    year = plist["year"] as? Int
    request = plist["request"] as! Bool
    timestamp = plist["timestamp"] as? Date
  }

  var dictionary: [String: AnyObject] { get {
    return [
      "artist": artist as AnyObject,
      "name": name as AnyObject,
      "album": album as AnyObject,
      "label": label as AnyObject,
      "year": year as AnyObject? ?? 0 as AnyObject,
      "request": request as AnyObject,
      "timestamp": (timestamp ?? Date()) as AnyObject
    ]
  } }
  
}

func ==(lhs: Song, rhs: Song) -> Bool {
  return (lhs.artist == rhs.artist) &&
         (lhs.name == lhs.name) &&
         (lhs.album == lhs.album)
}
