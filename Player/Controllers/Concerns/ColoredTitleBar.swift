//
//  ColoredTitleBar.swift
//  Player
//
//  Created by Cameron Bothner on 6/15/18.
//  Copyright © 2018 Cameron Bothner. All rights reserved.
//

protocol ColoredTitleBar {
  var titleBarColor: UIColor { get }
  var titleBarDark: Bool { get }
}

private extension ColoredTitleBar {
  var titleBarContentsColor: UIColor {
    return titleBarDark ? UIColor.white : UIColor.black
  }
}

extension ColoredTitleBar where Self: UIViewController {
  func setTitleBarColor() {
    if let bar = navigationController?.navigationBar {
      bar.isTranslucent = false
      bar.barTintColor = titleBarColor
      bar.tintColor = titleBarContentsColor
      bar.titleTextAttributes = [
        .font: UIFont(name: "Lato-Black", size: 17)!,
        .foregroundColor: titleBarContentsColor
      ]
      bar.setNeedsLayout()
      bar.layoutIfNeeded()
      bar.setNeedsDisplay()
    }

    if let navigationController = self.navigationController {
      navigationController.setNeedsStatusBarAppearanceUpdate()
    } else {
      setNeedsStatusBarAppearanceUpdate()
    }
  }

  func animateTitleBarColor() {
    transitionCoordinator?.animate(alongsideTransition: { [weak self] (_) in
      self?.setTitleBarColor()
    }, completion: nil)
  }
}

extension UINavigationController {
  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return visibleViewController?.preferredStatusBarStyle ?? .default
  }
}
