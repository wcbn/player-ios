//
//  LightStatusBarNavigationController.swift
//  player
//
//  Created by Cameron Bothner on 3/27/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class LightStatusBarNavigationController: UINavigationController {

  var light = true {
    didSet {
      self.setNeedsStatusBarAppearanceUpdate()
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.setNeedsStatusBarAppearanceUpdate()
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    if light {
      return .LightContent
    } else {
      return .Default
    }
  }

}

extension UINavigationController {
  public override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.Default
  }
}