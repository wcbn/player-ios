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

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let action = STVC.settings[settingsGroup]![indexPath.section].settings[indexPath.row]

    switch action.key {

    case "call": callWCBN()
    case "text": textWCBN()
    case WCBNStream.URL.high,
         WCBNStream.URL.medium,
         WCBNStream.URL.low:
      delegate.streamURL = action.key
      navigationController?.popViewControllerAnimated(true)

    case let value where SongSearchServiceChoice.rawValues.contains(value):
      let choice = SongSearchServiceChoice(rawValue: action.key)
      let svc = getSongSearchService(byChoice: choice ?? .iTunes)
      delegate.songSearchService = svc
      navigationController?.popViewControllerAnimated(true)

    case "review":
      let reviewURL = NSURL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=600658964&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")
      UIApplication.sharedApplication().openURL(reviewURL!)
      deselectSelectedRow()

    case "UM-OUD":
      let giftURL = NSURL(string: "https://leadersandbest.umich.edu/find/#!/give/basket/fund/361991")
      UIApplication.sharedApplication().openURL(giftURL!)
      deselectSelectedRow()

    default:
      let nextSettingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsTableViewController
      nextSettingsVC.settingsGroup = action.key
      self.navigationController?.pushViewController(nextSettingsVC, animated: true)

    }
  }


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