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

func hit(url: NSURL,
         containingBody body: JSON = nil,
         using method: String = "GET",
         withHeaders headers: [String:String] = [:],
         then callback: (JSON) -> Void) {
  let request = NSMutableURLRequest(URL: url)

  headers.forEach { key, value in
    request.setValue(value, forHTTPHeaderField: key)
  }

  request.HTTPMethod = method

  do {
    try request.HTTPBody = body.rawData()
  } catch {}

  NSURLSession.sharedSession().dataTaskWithRequest(request) { data, _, error in
    if data != nil && data!.length > 0 && error == nil {
      let json = JSON(data: data!)
      callback(json)
    }
  }.resume()
}
