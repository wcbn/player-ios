//
//  markdown.swift
//  Player
//
//  Created by Cameron Bothner on 6/15/18.
//  Copyright © 2018 Cameron Bothner. All rights reserved.
//

import Foundation
import Down

struct MD {
  static func toAttributedString(
    _ markdown: String,
    withBlackText dark: Bool = false
  ) -> NSAttributedString? {
    let markdown = Down(markdownString: markdown)
    return try? markdown
      .toAttributedString(stylesheet: markdownStylesheet(dark: dark))
      .trailingNewlineChopped
  }
}

fileprivate func markdownStylesheet(dark: Bool) -> String? {
  var stylesheet = "body { color: \(dark ? "black" : "white"); }"
  if let typography = try? String(
    contentsOfFile: Bundle.main.path(forResource: "typography", ofType: "css")!
  ) {
    stylesheet += typography
  }
  stylesheet += imageWidthStyling()
  return stylesheet
}

fileprivate func imageWidthStyling() -> String {
  return "img { max-width: \(UIScreen.main.bounds.width)px; }"
}
