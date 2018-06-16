//
//  UserDefaultsKeys.swift
//  Player
//
//  Created by Cameron Bothner on 6/16/18.
//  Copyright © 2018 Cameron Bothner. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {

  struct ExplainedInterface {

    // The user has demonstrated that they know how to use the radial menu.
    static let radialMenu = "interfaceExplained[radialMenu]"

  }

  struct Settings {

    // What song search service to use
    static let songService = "songSearchServiceChoice"

    // The user’s choice of stream
    static let streamURL = "WCBNStreamURL"

  }

  // Save the user’s favorites
  static let favourites = "Favourites"

  // Have we prompted the user for a review yet this version?
  static let lastVersionPromptedForReview = "LastVersionPromptedForReview"

  // The user has played music at least once. If this is set, we autoplay
  // instead of starting paused to let the user discover the play button.
  static let launchedBefore = "LaunchedBefore"

  // How many times has the user launched the app?
  static var launchCount = "LaunchCount"

  // An identifier of the user’s device that we’re allowed to send along with
  // Tip Jar logs
  static let uid = "UID"

}
