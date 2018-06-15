//
//  SwiftyJSONDateTime.swift
//  player
//
//  Created by Cameron Bothner on 3/25/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import Foundation
import SwiftyJSON

// From https://github.com/SwiftyJSON/SwiftyJSON/issues/421

extension JSON {

  public var date: Date? {
    get {
      switch self.type {
      case .string:
        return Formatter.jsonDateFormatter.date(from: self.object as! String)
      default:
        return nil
      }
    }
  }

  public var dateTime: Date? {
    get {
      switch self.type {
      case .string:
        return Formatter.jsonDateTimeFormatter.date(from: self.object as! String)
      default:
        return nil
      }
    }
  }

}

class Formatter {

  fileprivate static var internalJsonDateFormatter: DateFormatter?
  fileprivate static var internalJsonDateTimeFormatter: DateFormatter?

  static var jsonDateFormatter: DateFormatter {
    if (internalJsonDateFormatter == nil) {
      internalJsonDateFormatter = DateFormatter()
      internalJsonDateFormatter!.dateFormat = "yyyy-MM-dd"
    }
    return internalJsonDateFormatter!
  }

  static var jsonDateTimeFormatter: DateFormatter {
    if (internalJsonDateTimeFormatter == nil) {
      internalJsonDateTimeFormatter = DateFormatter()
      internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    }
    return internalJsonDateTimeFormatter!
  }

}
