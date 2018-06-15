//
//  ColoredTitleBarViewController.swift
//  Player
//
//  Created by Cameron Bothner on 6/15/18.
//  Copyright © 2018 Cameron Bothner. All rights reserved.
//

class ColoredTitleBarViewController: UIViewController {

  var titleBarColor: UIColor { return Colors.Dark.blue }
  var titleBarDark: Bool { return true }

  var titleBarContentsColor: UIColor {
    return titleBarDark ? UIColor.white : UIColor.black
  }

  // MARK: Lifecycle

  override func viewDidAppear(_ animated: Bool) {
    setTitleBarColor()
  }

  override func willMove(toParentViewController parent: UIViewController?) {
    guard let vcs = navigationController?.viewControllers else { return }
    guard let last = vcs.last as? ColoredTitleBarViewController else { return }
    guard last == self && vcs.count > 1 else { return }
    guard let parent = vcs[vcs.count - 2] as? ColoredTitleBarViewController
      else { return }

    parent.setTitleBarColor()
  }

  override func viewWillDisappear(_ animated: Bool) {
    guard let parent = navigationController?.viewControllers.last
      as? ColoredTitleBarViewController else { return }
    parent.animateTitleBarColor()
  }

  // MARK: Helpers

  func setTitleBarColor() {
    if let bar = navigationController?.navigationBar {
      bar.isTranslucent = false
      bar.barTintColor = titleBarColor
      bar.tintColor = titleBarContentsColor
      bar.titleTextAttributes = [
        .font: UIFont(name: "Lato-Black", size: 17)!,
        .foregroundColor: titleBarContentsColor
      ]
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
  override open var childViewControllerForStatusBarStyle: UIViewController? {
    return visibleViewController
  }
}
