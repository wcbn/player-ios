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

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let action = STVC.settings[settingsGroup]![indexPath.section].settings[indexPath.row]

    switch action.key {

    case "call": callWCBN()
    case "text": textWCBN()
    case WCBNStream.URL.high,
         WCBNStream.URL.medium,
         WCBNStream.URL.low:
      delegate.streamURL = action.key
      navigationController?.popViewController(animated: true)

    case let value where SongSearchServiceChoice.rawValues.contains(value):
      let choice = SongSearchServiceChoice(rawValue: action.key)
      let svc = getSongSearchService(byChoice: choice ?? .iTunes)
      delegate.songSearchService = svc
      navigationController?.popViewController(animated: true)

    case "review":
      let reviewURL = URL(string: "https://itunes.apple.com/us/app/wcbn/id600658964?action=write-review")
      UIApplication.shared.openURL(reviewURL!)
      deselectSelectedRow()

    case "give":
      let tipJar = self.storyboard?.instantiateViewController(withIdentifier: "TipJarTableView") as! TipJarTableViewController
      self.navigationController?.pushViewController(tipJar, animated: true)

    default:
      let nextSettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsTableViewController
      nextSettingsVC.settingsGroup = action.key
      self.navigationController?.pushViewController(nextSettingsVC, animated: true)

    }
  }

  func callWCBN() {
    let alert = UIAlertController(title: "Call WCBN", message: "Hit call to give us a ring. Unfortunately, the music will have to be paused and long-distance charges may ensue.", preferredStyle: .alert)
    let call = UIAlertAction(title: "Call", style: .default) { action in
      let studioPhone = URL(string: "tel://+1-734-763-3500")!
      UIApplication.shared.openURL(studioPhone)
    }
    alert.addAction(call)
    let dismiss = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(dismiss)
    present(alert, animated: true, completion: deselectSelectedRow)
  }

  func textWCBN() {

    if !MFMessageComposeViewController.canSendText() {
      let alert = UIAlertController(title: "Cannot send", message: "This device does not support sending iMessages.", preferredStyle: .alert)
      let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(dismiss)
      present(alert, animated: true, completion: deselectSelectedRow)
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

  func deselectSelectedRow() {
    if let selected = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: selected, animated: true)
    }
  }
}
