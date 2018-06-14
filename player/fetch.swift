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
  DispatchQueue.global(qos: .background).async {
    if let response = try? Data(contentsOf: endpointURL) {
      DispatchQueue.main.async {
        callback(response)
      }
    } else { fallback() }
  }
}

func fetch(jsonFrom endpointURL: URL, then callback: @escaping (JSON) -> Void) {
  fetch(dataFrom: endpointURL) { r in
    guard let json = try? JSON(data: r) else { return }
    callback(json)
  }
}

func hit(_ url: URL,
         containingBody body: JSON = JSON.null,
         using method: String = "GET",
         withHeaders headers: [String:String] = [:],
         then callback: @escaping (JSON) -> Void) {
  var request = URLRequest(url: url)

  headers.forEach { (arg) in

    let (key, value) = arg
    request.setValue(value, forHTTPHeaderField: key)
  }

  request.httpMethod = method

  do {
    try request.httpBody = body.rawData()
  } catch {}

  URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
    if data != nil && data!.count > 0 && error == nil {
      guard let json = try? JSON(data: data!) else { return }
      callback(json)
    }
  }).resume()
}
