//
//  RadioVCRadialMenu.swift
//  player
//
//  Created by Cameron Bothner on 5/13/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit
import MessageUI

extension RadioViewController {
  func loadRadialMenu() {
    let service = delegate.songSearchService
    options[2] = RadialOption(name: "act-\(service.name)", message: service.message, color: service.color)
    blurBehindRadialMenu.contentView.subviews.forEach { subview in subview.removeFromSuperview() }

    var subMenus: [RadialSubMenu] = []
    for i in 0..<options.count{
      subMenus.append(self.createSubMenu(i))
    }
    radialMenu = RadialMenu(menus: subMenus, radius: 130.0)
    radialMenu.center = albumArt.center
    radialMenu.openDelayStep = 0.05
    radialMenu.closeDelayStep = 0.00
    radialMenu.minAngle = -90
    radialMenu.maxAngle = 270
    radialMenu.activatedDelay = 0.0
    radialMenu.backgroundView.alpha = 0.5

    radialMenu.onClose = {
      for subMenu in self.radialMenu.subMenus {
        self.resetSubMenu(subMenu)
      }
    }
    radialMenu.onHighlight = { subMenu in self.highlightSubMenu(subMenu) }
    radialMenu.onUnhighlight = { subMenu in self.resetSubMenu(subMenu) }
    radialMenu.onActivate = { subMenu in self.activateSubMenu(subMenu)}

    blurBehindRadialMenu.hidden = true
    tabBarController?.view.addSubview(blurBehindRadialMenu)
    blurBehindRadialMenu.contentView.addSubview(radialMenu)

    radialMenuHint.font = UIFont(name: "Lato-Bold", size: 16)
    radialMenuHint.textColor = UIColor.whiteColor()
    radialMenuHint.text = ""
    blurBehindRadialMenu.contentView.addSubview(radialMenuHint)


  }

  func setRadialMenuHint(text: String) {
    let r = radialMenuHint
    r.text = text
    r.sizeToFit()
    r.center = CGPoint(x: albumArt.center.x, y: albumArt.center.y - 60 - albumArt.frame.height / 2)
  }

  @IBAction func longPressed(gesture:UIGestureRecognizer) {
    if !delegate.radio!.isPlaying { return }
    let loc = gesture.locationInView(blurBehindRadialMenu)
    switch(gesture.state) {
    case .Began:
      openRadialMenu(loc)
    case .Ended:
      closeRadialMenu()
    case .Changed:
      radialMenu.moveAtPosition(loc)
    default:
      break
    }
  }

  func openRadialMenu(location: CGPoint) {
    blurBehindRadialMenu.frame = view.bounds
    UIView.transitionWithView(blurBehindRadialMenu, duration: 0.1, options: .TransitionCrossDissolve,
                              animations: { self.blurBehindRadialMenu.hidden = false },
                              completion: nil)
    
    setRadialMenuHint("Tap once to stop streaming")
    
    radialMenu.openAtPosition(location)
  }

  func closeRadialMenu() {
    UIView.transitionWithView(blurBehindRadialMenu, duration: 0.1, options: .TransitionCrossDissolve,
                              animations: { self.blurBehindRadialMenu.hidden = true },
                              completion: nil)
    radialMenu.close()
  }

  func createSubMenu(i: Int) -> RadialSubMenu {
    let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
    image.image = UIImage(named: options[i].name)!
    let subMenu = RadialSubMenu(imageView: image)
    subMenu.layer.cornerRadius = 80
    subMenu.userInteractionEnabled = true
    subMenu.tag = i
    resetSubMenu(subMenu)
    return subMenu
  }
  
  func highlightSubMenu(subMenu: RadialSubMenu) {
    let opt = options[subMenu.tag]
    let svc = delegate.songSearchService
    if opt.name == "act-\(svc.name)" && !svc.canEnplaylist {
      setRadialMenuHint("Song cannot be found in \(svc.name)")
    } else {
      setRadialMenuHint(opt.message)
      UIView.animateWithDuration(0.1) {
        subMenu.transform = CGAffineTransformMakeScale(1.25, 1.25)
      }
    }

    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setBool(true, forKey: "interfaceExplained[RadialMenu]")
  }

  func resetSubMenu(subMenu: RadialSubMenu) {
    setRadialMenuHint("Tap once to stop streaming")
    UIView.animateWithDuration(0.1) {
      subMenu.transform = CGAffineTransformMakeScale(0.8, 0.8)  // = 1 / 1.25
    }
  }

  func activateSubMenu(subMenu: RadialSubMenu) {
    let svc = delegate.songSearchService
    let option = options[subMenu.tag]
    switch option.name {
    case "act-heart":
      starSong()
      flash(UIColor(rgba: option.color))
    case "act-\(svc.name)":
      if svc.canEnplaylist {
        svc.enplaylist() { }
        flash(UIColor(rgba: option.color))
      } else {
        let alert = UIAlertController(title: "Cannot Save Song", message: "This song cannot be found in the \(svc.name) library.", preferredStyle: .Alert)
        let dismiss = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(dismiss)
        presentViewController(alert, animated: true, completion: nil)
      }
    case "act-message":
      flash(UIColor(rgba: option.color))
      textWCBN()
    case "act-share":
      shareSong()
    default:
      break
    }
  }

  func shareSong() {
    let description = delegate.radio?.optionalDescription
    let on = description == nil ? "" : " on "
    let content = "I’m listening to \(description ?? "")\(on)WCBN-FM. Tune in at wcbn.org!"

    let shareSheet = UIActivityViewController(activityItems: [content as NSString], applicationActivities: nil)
    shareSheet.modalPresentationStyle = .Popover
    presentViewController(shareSheet, animated: true, completion: nil)
    let popoverController = shareSheet.popoverPresentationController
    popoverController?.sourceView = albumArt
    popoverController?.sourceRect = albumArt.bounds
  }

  func textWCBN() {
    if !MFMessageComposeViewController.canSendText() {
      let alert = UIAlertController(title: "Cannot send", message: "This device does not support sending iMessages.", preferredStyle: .Alert)
      let dismiss = UIAlertAction(title: "OK", style: .Default, handler: nil)
      alert.addAction(dismiss)
      presentViewController(alert, animated: true, completion: nil)
      return
    }

    let composeView = MFMessageComposeViewController()
    composeView.messageComposeDelegate = self

    composeView.recipients = ["radio@wcbn.org"]
    presentViewController(composeView, animated: true, completion: nil)
  }

  func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }

  func flash(color: UIColor) {
    UIView.animateWithDuration(0.3, animations: {
      self.view.backgroundColor = color
    }, completion: { _ in
      UIView.animateWithDuration(0.3) { self.view.backgroundColor = Colors.Light.blue }
    })
  }




  func explainRadialMenu() {
    delay(1) {
      self.openRadialMenu(self.albumArt.center)
      self.setRadialMenuHint("Tap and hold the album artwork to do more")

      let tapRecog = UITapGestureRecognizer(target: self, action: #selector(self.endExplainRadialMenu))
      self.blurBehindRadialMenu.addGestureRecognizer(tapRecog)
    }
  }

  func endExplainRadialMenu() {
    closeRadialMenu()
    if let recogs = blurBehindRadialMenu.gestureRecognizers {
      for recog in recogs {
        blurBehindRadialMenu.removeGestureRecognizer(recog)
      }
    }
  }
}
