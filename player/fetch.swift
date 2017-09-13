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
     dataFrom endpointURL: URL,
     onFailure fallback: @escaping () -> Void = {},
     then callback: @escaping (Data) -> Void
  ) {
  let backgroundQOS = Int(DispatchQoS.QoSClass.background.rawValue)
  DispatchQueue.global(priority: backgroundQOS).async {
    if let response = try? Data(contentsOf: endpointURL) {
      DispatchQueue.main.async {
        callback(response)
      }
    } else { fallback() }
  }
}

func fetch(jsonFrom endpointURL: URL, then callback: (JSON) -> Void) {
  fetch(dataFrom: endpointURL) { r in
    let json = JSON(data: r)
    callback(json)
  }
}

func hit(_ url: URL,
         containingBody body: JSON = nil,
         using method: String = "GET",
         withHeaders headers: [String:String] = [:],
         then callback: (JSON) -> Void) {
  let request = NSMutableURLRequest(url: url)

  headers.forEach { key, value in
    request.setValue(value, forHTTPHeaderField: key)
  }

  request.httpMethod = method

  do {
    try request.HTTPBody = body.rawData()
  } catch {}

  URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
    if data != nil && data!.count > 0 && error == nil {
      let json = JSON(data: data!)
      callback(json)
    }
  }) .resume()
}
