//
//  Song.swift
//  player
//
//  Created by Cameron Bothner on 2016/04/10.
//  Copyright © 2016年 Cameron Bothner. All rights reserved.
//

import Foundation

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
}

func ==(lhs: Song, rhs: Song) -> Bool {
  return (lhs.artist == rhs.artist) &&
         (lhs.name == lhs.name) &&
         (lhs.album == lhs.album)
}