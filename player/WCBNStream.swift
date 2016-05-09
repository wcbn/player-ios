//
//  WCBNStream.swift
//  player
//
//  Created by Cameron Bothner on 3/28/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import Foundation

struct WCBNStream {
  struct URL {
    static let high = "http://www.wcbn.org/wcbn-hd.m3u"
    static let medium = "http://www.wcbn.org/wcbn-hi.m3u"
    static let low = "http://www.wcbn.org/wcbn-mid.m3u"
  }
  static let nameFromURL = [
    URL.high: "HD (320 kbps)",
    URL.medium: "Normal (128 kbps)",
    URL.low: "Low (64 kbps)"
  ]
}