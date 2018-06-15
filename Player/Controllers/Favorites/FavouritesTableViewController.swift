//
//  FavoritesTableViewController.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 3/1/15.
//  Copyright (c) 2015 Cameron Bothner. All rights reserved.
//

import UIKit

class FavouritesTableViewController: UITableViewController {
  
  var fav = Favourites()
  
  fileprivate struct Storyboard {
    static let CellReuseIdentifier = "Favourite"
  }

  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // cell height
    tableView.estimatedRowHeight = tableView.rowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setTitleBarColor()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
  }

  // MARK: - UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if fav.needsInstructions() { return 1 }

    return fav.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if fav.needsInstructions() {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Instructions") as! InstructionsTableViewCell
      cell.backgroundColor = Colors.Dark.pink
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath) as! FavouriteTableViewCell
    cell.p = fav[indexPath.row]
    cell.backgroundColor = UIColor.clear
    
    let selectionColor = UIView()
    selectionColor.backgroundColor = UIColor.white
    cell.selectedBackgroundView = selectionColor
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let content = fav[indexPath.row].song.description

    let shareSheet = UIActivityViewController(activityItems: [content as NSString], applicationActivities: nil)
    shareSheet.modalPresentationStyle = .popover
    present(shareSheet, animated: true, completion: deselectSelectedRow)
    let popoverController = shareSheet.popoverPresentationController
    let cell = tableView.cellForRow(at: indexPath)!
    popoverController?.sourceView = cell
    popoverController?.sourceRect = cell.bounds
  }
  func deselectSelectedRow() {
    if let selected = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: selected, animated: true)
    }
  }

  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if fav.needsInstructions() { return false }
    return true
  }

  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    // Necessary to enable the edit actions at all
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

    var actions: [UITableViewRowAction] = []

    let deleteButton = UITableViewRowAction(style: .default, title: "Delete") { _, inxPth in
      self.fav.removeAtIndex(inxPth.row)
      tableView.deleteRows(at: [inxPth], with: .bottom)
    }
    deleteButton.backgroundColor = Colors.Dark.red
    actions.append(deleteButton)

    return actions.reversed()
  }
}

// MARK: - ColoredTitleBar
extension FavouritesTableViewController: ColoredTitleBar {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent

  }
  var titleBarColor: UIColor { return Colors.Dark.pink }
  var titleBarDark: Bool { return true }
}
