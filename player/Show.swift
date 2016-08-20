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
  var start = NSDate()
  var end = NSDate()
  var onAir = false
  var episodes: [Episode]? = nil

  var url: NSURL {
    get { return NSURL(string: "http://app.wcbn.org\(url_for).json")! }
  }
  var times: String {
    get {
      let dateFormatter = NSDateFormatter()
      dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
      let beginning = dateFormatter.stringFromDate(start)
      let ending = dateFormatter.stringFromDate(end)
      return "\(beginning)–\(ending)"
    }
  }

  init() {  }
  
  init(fromJSON json: JSON) {
    url_for = json["url"].stringValue
    name = json["name"].stringValue
    description = json["description"].stringValue
    with = json["with"].stringValue
    start = json["beginning"].dateTime!
    end = json["ending"].dateTime!
    onAir = json["on_air"].boolValue
    episodes = nil

    djs = json["djs"].arrayValue.map { dj in
      return Show.DJ(name: dj["name"].stringValue, path: dj["url"].stringValue)
    }
  }
}