//
//  NSAttributedString.swift
//  Player
//
//  Created by Cameron Bothner on 6/15/18.
//  Copyright © 2018 Cameron Bothner. All rights reserved.
//

import Foundation

extension NSAttributedString {
  var trailingNewlineChopped: NSAttributedString {
    guard string.hasSuffix("\n") else { return self }

    return self.attributedSubstring(
      from: NSRange(location: 0, length: length - 1)
    )
  }
}
