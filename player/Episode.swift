//
//  Episode.swift
//  player
//
//  Created by Cameron Bothner on 2016/04/10.
//  Copyright © 2016年 Cameron Bothner. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Episode {
  var name = ""
  var dj = ""
  var dj_path = ""
  var beginning: Date? = nil
  var ending: Date? = nil
  var notes: String? = nil
  var songs: [Song]? = nil


  var at : String {
    get {
      if let t = beginning {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        return dateFormatter.string(from: t)
      }
      else { return "" }
    }
  }

  var unambiguousName: String {
    get {
      if name == "Freeform" {
        return "Freeform w/ \(dj)"
      } else {
        return name
      }
    }
  }

  var numberOfNotesCells: Int {
    get {
      if notes == nil || notes == "" {
        return 0
      } else {
        return 1
      }
    }
  }

  init() {  }

  init(fromJSON json: JSON) {
    name = json["name"].stringValue
    dj = json["dj"].stringValue
    dj_path = json["dj_url"].stringValue
    beginning = json["beginning"].dateTime
    ending = json["ending"].dateTime
    notes = json["show_notes"].string
    songs = json["songs"].array?.map { song in return Song(fromJSON: song) }
  }

  init(fromPlist plist: [String: AnyObject]) {
    name = plist["name"] as! String
    dj = plist["dj"] as! String
  }

  var dictionary: [String: AnyObject] { get {
    return ["name": name as AnyObject, "dj": dj as AnyObject]
  } }
}
