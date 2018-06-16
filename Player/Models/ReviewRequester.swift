//
//  ReviewRequester.swift
//  Player
//
//  Created by Cameron Bothner on 6/16/18.
//  Copyright © 2018 Cameron Bothner. All rights reserved.
//

import Foundation
import StoreKit

@available(iOS 10.3, *)
class ReviewRequester {

  static func maybeRequestReview() {
    let launchCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.launchCount)
    guard launchCount > 3 else { return }

    let infoDictionaryKey = kCFBundleVersionKey as String
    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
      else { fatalError("Expected to find a bundle version in the info dictionary") }

    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReview)

    guard currentVersion != lastVersionPromptedForReview else { return }

    let twoSecondsFromNow = DispatchTime.now() + 2.0
    DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
        SKStoreReviewController.requestReview()
        UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReview)
    }
  }

}
