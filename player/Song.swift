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
  var timestamp: NSDate? = nil

  var blank: Bool {
    get {
      return self == Song()
    }
  }

  var at : String {
    get {
      if let t = timestamp {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return dateFormatter.stringFromDate(t)
      }
      else { return "" }
    }
  }
  var longAt: String {
    get {
      if let t = timestamp {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(t)
      } else { return "" }
    }
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
    timestamp = plist["timestamp"] as? NSDate
  }

  var dictionary: [String: AnyObject] { get {
    return [
      "artist": artist,
      "name": name,
      "album": album,
      "label": label,
      "year": year ?? 0,
      "request": request,
      "timestamp": timestamp ?? NSDate()
    ]
  } }
  
}

func ==(lhs: Song, rhs: Song) -> Bool {
  return (lhs.artist == rhs.artist) &&
         (lhs.name == lhs.name) &&
         (lhs.album == lhs.album)
}