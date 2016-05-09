//
//  SettingsActions.swift
//  player
//
//  Created by Cameron Bothner on 3/27/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit
import MessageUI

extension SettingsTableViewController {

  func callWCBN() {
    let alert = UIAlertController(title: "Call WCBN", message: "Hit call to give us a ring. Unfortunately, the music will have to be paused and long-distance charges may ensue.", preferredStyle: .Alert)
    let call = UIAlertAction(title: "Call", style: .Default) { action in
      let studioPhone = NSURL(string: "tel://+1-734-763-3500")!
      UIApplication.sharedApplication().openURL(studioPhone)
    }
    alert.addAction(call)
    let dismiss = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alert.addAction(dismiss)
    presentViewController(alert, animated: true, completion: deselectSelectedRow)
  }

  func textWCBN() {

    if !MFMessageComposeViewController.canSendText() {
      let alert = UIAlertController(title: "Cannot send", message: "This device does not support sending iMessages.", preferredStyle: .Alert)
      let dismiss = UIAlertAction(title: "OK", style: .Default, handler: nil)
      alert.addAction(dismiss)
      presentViewController(alert, animated: true, completion: deselectSelectedRow)
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

  func deselectSelectedRow() {
    if let selected = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRowAtIndexPath(selected, animated: true)
    }
  }
}