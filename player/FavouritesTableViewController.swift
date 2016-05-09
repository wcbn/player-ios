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
  
  private struct Storyboard {
    static let CellReuseIdentifier = "Favourite"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // navigation bar color
    let bar = self.navigationController?.navigationBar
    bar?.translucent = false
    bar?.barTintColor = Colors.Dark.pink
    bar?.titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Lato-Black", size: 17)!,
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]

    // cell height
    tableView.estimatedRowHeight = tableView.rowHeight
    tableView.rowHeight = UITableViewAutomaticDimension

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    tableView.reloadData()
  }

  // MARK: - UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if fav.needsInstructions() { return 1 }

    return fav.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if fav.needsInstructions() {
      let cell = tableView.dequeueReusableCellWithIdentifier("Instructions") as! InstructionsTableViewCell
      cell.backgroundColor = Colors.Dark.pink
      return cell
    }

    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! FavouriteTableViewCell
    cell.p = fav[indexPath.row]
    cell.backgroundColor = UIColor.clearColor()
    return cell
  }

  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if fav.needsInstructions() { return false }
    return true
  }

  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    // Necessary to enable the edit actions at all
  }

  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

    var actions: [UITableViewRowAction] = []

    if fav[indexPath.row].url != nil {
      let searchButton = UITableViewRowAction(style: .Default, title: "iTunes") {
        _, inxPth in
        let url = self.fav[inxPth.row].url!
        UIApplication.sharedApplication().openURL(url)
      }
      searchButton.backgroundColor = Colors.Light.green
      actions.append(searchButton)
    }

    let deleteButton = UITableViewRowAction(style: .Destructive, title: "Delete") { _, inxPth in
      self.fav.removeAtIndex(inxPth.row)
      tableView.deleteRowsAtIndexPaths([inxPth], withRowAnimation: .Bottom)
    }
    deleteButton.backgroundColor = Colors.Dark.red
    actions.append(deleteButton)

    return actions.reverse()
  }

  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
}
