//
//  ScheduleTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 3/25/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {

  let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
  var semesterDuration = ""
  var shouldScrollToCurrentShow = true

  private struct Storyboard {
    static let CellReuseIdentifier = "Show"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    notificationCenter.addObserverForName("PlaylistDataReceived",
                                          object: nil,
                                          queue: mainQueue)
    { _ in
      self.tableView.reloadData()
      self.shouldScrollToCurrentShow = true
      if let onAir = self.delegate.radio!.playlist.showOnAir {
        self.tableView.selectRowAtIndexPath(onAir, animated: true, scrollPosition: .Top)
      }
    }

    let bar = self.navigationController?.navigationBar
    bar?.translucent = false
    bar?.tintColor = UIColor.whiteColor()
    bar?.barTintColor = Colors.Dark.orange
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

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.barTintColor = Colors.Dark.orange
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if let onAir = delegate.radio!.playlist.showOnAir {
      if shouldScrollToCurrentShow {
        tableView.selectRowAtIndexPath(onAir, animated: true, scrollPosition: .Top)
      } else {
        tableView.selectRowAtIndexPath(onAir, animated: true, scrollPosition: .None)
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return delegate.radio!.playlist.schedule.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return delegate.radio!.playlist.schedule[section].shows.count
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let dF = NSDateFormatter()
    return dF.standaloneWeekdaySymbols[delegate.radio!.playlist.schedule[section].index % 7]
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell

    cell.show = delegate.radio!.playlist.schedule[indexPath.section].shows[indexPath.row]

    cell.backgroundColor = UIColor.clearColor()

    let selectionColor = UIView()
    selectionColor.backgroundColor = UIColor.whiteColor()
    cell.selectedBackgroundView = selectionColor

    return cell
  }

  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.contentView.backgroundColor = Colors.Dark.orange
    header.textLabel?.textColor = UIColor.whiteColor()
    header.textLabel?.font = UIFont(name: "Lato-Black", size: 14)!
  }

  override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    let dF = NSDateFormatter()
    let weekdays = dF.veryShortWeekdaySymbols
    var weekdaysWithMondayStart = weekdays[1..<7]
    weekdaysWithMondayStart += weekdays[0..<1]
    return Array(weekdaysWithMondayStart)
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    shouldScrollToCurrentShow = false
    let show = delegate.radio!.playlist.schedule[indexPath.section].shows[indexPath.row]

    let showVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("ShowDetails") as! ShowDetailViewController
    showVC.show = show
    showVC.title = show.name

    let back = UIBarButtonItem()
    back.title = "Schedule"
    self.navigationItem.backBarButtonItem = back

    self.navigationController?.pushViewController(showVC, animated: true)
  }
}
