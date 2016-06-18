//
//  fetch.swift
//  player
//
//  Created by Cameron Bothner on 6/18/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import Foundation
import SwiftyJSON

func fetch(
     dataFrom endpointURL: NSURL,
     onFailure fallback: () -> Void = {},
     then callback: (NSData) -> Void
  ) {
  let backgroundQOS = Int(QOS_CLASS_BACKGROUND.rawValue)
  dispatch_async(dispatch_get_global_queue(backgroundQOS, 0)) {
    if let response = NSData(contentsOfURL: endpointURL) {
      dispatch_async(dispatch_get_main_queue()) {
        callback(response)
      }
    } else { fallback() }
  }
}

func fetch(jsonFrom endpointURL: NSURL, then callback: (JSON) -> Void) {
  fetch(dataFrom: endpointURL) { r in
    let json = JSON(data: r)
    callback(json)
  }
}