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

    blurBehindRadialMenu.isHidden = true
    tabBarController?.view.addSubview(blurBehindRadialMenu)
    blurBehindRadialMenu.contentView.addSubview(radialMenu)

    radialMenuHint.font = UIFont(name: "Lato-Bold", size: 16)
    radialMenuHint.textColor = UIColor.white
    radialMenuHint.text = ""
    blurBehindRadialMenu.contentView.addSubview(radialMenuHint)


  }

  func setRadialMenuHint(_ text: String) {
    let r = radialMenuHint
    r.text = text
    r.sizeToFit()
    r.center = CGPoint(x: albumArt.center.x, y: albumArt.center.y - 60 - albumArt.frame.height / 2)
  }

  @IBAction func longPressed(_ gesture:UIGestureRecognizer) {
    if !delegate.radio!.isPlaying { return }
    let loc = gesture.location(in: blurBehindRadialMenu)
    switch(gesture.state) {
    case .began:
      openRadialMenu(loc)
    case .ended:
      closeRadialMenu()
    case .changed:
      radialMenu.moveAtPosition(loc)
    default:
      break
    }
  }

  func openRadialMenu(_ location: CGPoint) {
    blurBehindRadialMenu.frame = view.bounds
    UIView.transition(with: blurBehindRadialMenu, duration: 0.1, options: .transitionCrossDissolve,
                              animations: { self.blurBehindRadialMenu.isHidden = false },
                              completion: nil)
    
    setRadialMenuHint("Tap once to stop streaming")
    
    radialMenu.openAtPosition(location)
  }

  func closeRadialMenu() {
    UIView.transition(with: blurBehindRadialMenu, duration: 0.1, options: .transitionCrossDissolve,
                              animations: { self.blurBehindRadialMenu.isHidden = true },
                              completion: nil)
    radialMenu.close()
  }

  func createSubMenu(_ i: Int) -> RadialSubMenu {
    let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
    image.image = UIImage(named: options[i].name)!
    let subMenu = RadialSubMenu(imageView: image)
    subMenu.layer.cornerRadius = 80
    subMenu.isUserInteractionEnabled = true
    subMenu.tag = i
    resetSubMenu(subMenu)
    return subMenu
  }
  
  func highlightSubMenu(_ subMenu: RadialSubMenu) {
    let opt = options[subMenu.tag]
    let svc = delegate.songSearchService
    if opt.name == "act-\(svc.name)" && !svc.canEnplaylist {
      setRadialMenuHint("Song cannot be found in \(svc.name)")
    } else {
      setRadialMenuHint(opt.message)
      UIView.animate(withDuration: 0.1, animations: {
        subMenu.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
      }) 
    }

    let defaults = UserDefaults.standard
    defaults.set(true, forKey: "interfaceExplained[radialMenu]")
  }

  func resetSubMenu(_ subMenu: RadialSubMenu) {
    setRadialMenuHint("Tap once to stop streaming")
    UIView.animate(withDuration: 0.1, animations: {
      subMenu.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)  // = 1 / 1.25
    }) 
  }

  func activateSubMenu(_ subMenu: RadialSubMenu) {
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
        let alert = UIAlertController(title: "Cannot Save Song", message: "This song cannot be found in the \(svc.name) library.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
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
    shareSheet.modalPresentationStyle = .popover
    present(shareSheet, animated: true, completion: nil)
    let popoverController = shareSheet.popoverPresentationController
    popoverController?.sourceView = albumArt
    popoverController?.sourceRect = albumArt.bounds
  }

  func textWCBN() {
    if !MFMessageComposeViewController.canSendText() {
      let alert = UIAlertController(title: "Cannot send", message: "This device does not support sending iMessages.", preferredStyle: .alert)
      let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(dismiss)
      present(alert, animated: true, completion: nil)
      return
    }

    let composeView = MFMessageComposeViewController()
    composeView.messageComposeDelegate = self

    composeView.recipients = ["radio@wcbn.org"]
    present(composeView, animated: true, completion: nil)
  }

  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismiss(animated: true, completion: nil)
  }

  func flash(_ color: UIColor) {
    UIView.animate(withDuration: 0.3, animations: {
      self.view.backgroundColor = color
    }, completion: { _ in
      UIView.animate(withDuration: 0.3, animations: { self.view.backgroundColor = Colors.Light.blue }) 
    })
  }




  func explainRadialMenu() {
    delay(1) {
      self.openRadialMenu(self.albumArt.center)
      self.setRadialMenuHint("Tap and hold, then swipe to select")

      let tapRecog = UITapGestureRecognizer(target: self, action: #selector(self.endExplainRadialMenu))
      self.blurBehindRadialMenu.addGestureRecognizer(tapRecog)
    }
  }

  @objc func endExplainRadialMenu() {
    closeRadialMenu()
    if let recogs = blurBehindRadialMenu.gestureRecognizers {
      for recog in recogs {
        blurBehindRadialMenu.removeGestureRecognizer(recog)
      }
    }
  }
}
