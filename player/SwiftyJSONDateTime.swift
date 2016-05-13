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

  public var date: NSDate? {
    get {
      switch self.type {
      case .String:
        return Formatter.jsonDateFormatter.dateFromString(self.object as! String)
      default:
        return nil
      }
    }
  }

  public var dateTime: NSDate? {
    get {
      switch self.type {
      case .String:
        return Formatter.jsonDateTimeFormatter.dateFromString(self.object as! String)
      default:
        return nil
      }
    }
  }

}

class Formatter {

  private static var internalJsonDateFormatter: NSDateFormatter?
  private static var internalJsonDateTimeFormatter: NSDateFormatter?

  static var jsonDateFormatter: NSDateFormatter {
    if (internalJsonDateFormatter == nil) {
      internalJsonDateFormatter = NSDateFormatter()
      internalJsonDateFormatter!.dateFormat = "yyyy-MM-dd"
    }
    return internalJsonDateFormatter!
  }

  static var jsonDateTimeFormatter: NSDateFormatter {
    if (internalJsonDateTimeFormatter == nil) {
      internalJsonDateTimeFormatter = NSDateFormatter()
      internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    }
    return internalJsonDateTimeFormatter!
  }

}