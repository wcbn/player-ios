//
//  Song.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 3/1/15.
//  Copyright (c) 2015 Cameron Bothner. All rights reserved.
//

import Foundation

struct Song: CustomStringConvertible {
    var title: String
    var artist: String
    var show: String
    var timestamp: NSDate
    var description: String {
        return "\(title) by \(artist)"
    }
}