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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.setNeedsStatusBarAppearanceUpdate()
  }

  override var preferredStatusBarStyle : UIStatusBarStyle {
    if light {
      return .lightContent
    } else {
      return .default
    }
  }

}

extension UINavigationController {
  open override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.default
  }
}
