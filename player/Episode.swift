//
//  Episode.swift
//  player
//
//  Created by Cameron Bothner on 2016/04/10.
//  Copyright © 2016年 Cameron Bothner. All rights reserved.
//

import Foundation

struct Episode {
  var name = "Loading…"
  var dj = ""
  var beginning: NSDate? = nil
  var ending: NSDate? = nil
  var notes: String? = nil
  var songs: [Song]? = nil


  var at : String {
    get {
      if let t = beginning {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        return dateFormatter.stringFromDate(t)
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
}
