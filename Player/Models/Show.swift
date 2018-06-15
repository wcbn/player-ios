//
//  Show.swift
//  player
//
//  Created by Cameron Bothner on 2016/04/10.
//  Copyright © 2016年 Cameron Bothner. All rights reserved.
//

import Foundation
import SwiftyJSON

class Show {
  struct DJ {
    var name = ""
    var path = ""
  }


  var url_for = ""
  var name = ""
  var description = ""
  var djs: [DJ] = []
  var with = ""
  var start: Date? = nil
  var end: Date? = nil
  var onAir = false
  var episodes: [Episode]? = nil

  var url: URL {
    get { return URL(string: "http://app.wcbn.org\(url_for).json")! }
  }
  var times: String {
    get {
      guard let _ = start, let _ = end else { return "Cancelled" }
      let dateFormatter = DateFormatter()
      dateFormatter.timeStyle = .short
      let beginning = dateFormatter.string(from: start!)
      let ending = dateFormatter.string(from: end!)
      return "\(beginning)–\(ending)"
    }
  }
  var timesWithWeekday: String {
    get {
      guard let _ = start else { return "Cancelled" }
      let dateFormatter = DateFormatter()
      dateFormatter.setLocalizedDateFormatFromTemplate("cccc")
      let weekday = dateFormatter.string(from: start!)
      return "\(weekday) \(times)"
    }
  }

  init() {  }
  
  init(fromJSON json: JSON) {
    url_for = json["url"].stringValue
    name = json["name"].stringValue
    description = json["description"].stringValue
    with = json["with"].stringValue
    start = json["beginning"].dateTime
    end = json["ending"].dateTime
    onAir = json["on_air"].boolValue
    episodes = nil

    djs = json["djs"].arrayValue.map { dj in
      return Show.DJ(name: dj["name"].stringValue, path: dj["url"].stringValue)
    }
  }
}
