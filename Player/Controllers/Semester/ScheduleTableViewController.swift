//
//  ScheduleTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 3/25/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {

  let delegate = UIApplication.shared.delegate as! AppDelegate
  var semesterDuration = ""
  var shouldScrollToCurrentShow = true

  fileprivate struct Storyboard {
    static let CellReuseIdentifier = "Show"
  }

  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let notificationCenter = NotificationCenter.default
    let mainQueue = OperationQueue.main
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "PlaylistDataReceived"),
                                          object: nil,
                                          queue: mainQueue)
    { _ in
      self.tableView.reloadData()
      self.shouldScrollToCurrentShow = true
      if let onAir = self.delegate.radio!.playlist.showOnAir {
        self.tableView.selectRow(at: onAir as IndexPath, animated: true, scrollPosition: .top)
      }
    }

    // cell height
    tableView.estimatedRowHeight = tableView.rowHeight
    tableView.rowHeight = UITableViewAutomaticDimension

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setTitleBarColor()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let onAir = delegate.radio!.playlist.showOnAir {
      if shouldScrollToCurrentShow {
        tableView.selectRow(at: onAir as IndexPath, animated: true, scrollPosition: .top)
      } else {
        tableView.selectRow(at: onAir as IndexPath, animated: true, scrollPosition: .none)
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return delegate.radio!.playlist.schedule.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return delegate.radio!.playlist.schedule[section].shows.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let dF = DateFormatter()
    return dF.standaloneWeekdaySymbols[delegate.radio!.playlist.schedule[section].index % 7]
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath) as! ScheduleTableViewCell

    cell.show = delegate.radio!.playlist.schedule[indexPath.section].shows[indexPath.row]

    cell.backgroundColor = UIColor.clear

    let selectionColor = UIView()
    selectionColor.backgroundColor = UIColor.white
    cell.selectedBackgroundView = selectionColor

    return cell
  }

  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.contentView.backgroundColor = Colors.Dark.orange
    header.textLabel?.textColor = UIColor.white
    header.textLabel?.font = UIFont(name: "Lato-Black", size: 14)!
  }

  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    let dF = DateFormatter()
    let weekdays = dF.veryShortStandaloneWeekdaySymbols!
    var weekdaysWithMondayStart = weekdays[1..<7]
    weekdaysWithMondayStart += weekdays[0..<1]
    return Array(weekdaysWithMondayStart)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    shouldScrollToCurrentShow = false
    let show = delegate.radio!.playlist.schedule[indexPath.section].shows[indexPath.row]

    let showVC = self.storyboard?
      .instantiateViewController(withIdentifier: "ShowDetails") as! ShowDetailViewController
    showVC.show = show
    showVC.title = show.name

    let back = UIBarButtonItem()
    back.title = "Schedule"
    self.navigationItem.backBarButtonItem = back

    self.navigationController?.pushViewController(showVC, animated: true)
  }
}

// MARK: - ColoredTitleBar
extension ScheduleTableViewController: ColoredTitleBar {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent

  }
  var titleBarColor: UIColor { return Colors.Dark.orange }
  var titleBarDark: Bool { return true }
}
