//
//  DJ.swift
//  player
//
//  Created by Cameron Bothner on 5/9/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import Foundation
import SwiftyJSON

class DJ {
  convenience init(from json: JSON) {
    self.init()
    id = json["id"].intValue
    dj_name = json["dj_name"].stringValue
    real_name = json["real_name"].string
    website = URL(string: json["website"].stringValue)
    about = json["about"].stringValue
  }

  var id: Int = 0
  var dj_name: String = ""
  var real_name: String? = nil
  var public_email: String? = nil
  var website: URL? = nil
  var about: String = ""

  var aboutWithAbsoluteUrls: String {
    get {
      guard let readbackUrls = try? NSRegularExpression(pattern: "(src|href)=\"/(?!/)")
        else { return self.about }

      return readbackUrls.stringByReplacingMatches(
        in: about,
        options: [],
        range: NSRange(location: 0, length: about.count),
        withTemplate: "$1=\"https://app.wcbn.org/"
      )
    }
  }

  var formattedAbout: NSAttributedString? {
    get {
      return MD.toAttributedString(aboutWithAbsoluteUrls, withBlackText: true)
    }
  }
}
