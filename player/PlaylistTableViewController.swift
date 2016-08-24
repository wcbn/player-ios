//
//  PlaylistTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 1/17/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController {

  let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
  var episode = Episode()

  private struct Storyboard {
    static let ShowNotesCellReuseIdentifier = "ShowNotes"
    static let SongCellReuseIdentifier = "Recent"
  }

  @IBOutlet weak var navTitle: UINavigationItem!
  @IBOutlet weak var djLabel: UILabel!
  @IBOutlet weak var djButton: UIButton!

  func setDataIfViewIsRecentlyPlayed() {
    if self == navigationController?.viewControllers[0] {
      episode = delegate.radio!.playlist.episode
    }
    tableView.reloadData()
  }

  func setTitle() {
    navTitle.title = "Playlist"
    if self == navigationController?.viewControllers[0] {
      navTitle.title = episode.unambiguousName
    } else {
      navTitle.title = episode.at
    }
  }

  func setDJInfo() {
    djButton.setTitle("\(episode.dj) ›", forState: .Normal)
    if self == navigationController?.viewControllers[0] {
      djLabel.text = "Today’s host:"
    } else {
      djLabel.text = "Host:"
    }
  }

  func updateUI() {
    setDataIfViewIsRecentlyPlayed()
    setTitle()
    setDJInfo()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let notificationCenter = NSNotificationCenter.defaultCenter()
    let mainQueue = NSOperationQueue.mainQueue()
    notificationCenter.addObserverForName("SongDataReceived",
                                          object: nil,
                                          queue: mainQueue)
    { _ in
      self.updateUI()
    }

    updateUI()

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
    tableView.reloadData()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let bar = self.navigationController?.navigationBar
    bar?.translucent = false
    bar?.barTintColor = Colors.Dark.green
    bar?.titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Lato-Black", size: 17)!,
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
  }


  @IBAction func openDJ() {
    let djVC = storyboard?.instantiateViewControllerWithIdentifier("DJ") as! DJViewController
    djVC.dj_path = episode.dj_path
    djVC.title = episode.dj
    navigationController?.pushViewController(djVC, animated: true)
  }

  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episode.numberOfNotesCells + (episode.songs?.count ?? 0)
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if (indexPath.row == 0 && episode.notes != nil && episode.notes != "") {
      let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ShowNotesCellReuseIdentifier, forIndexPath: indexPath) as! ShowNotesTableViewCell
      cell.backgroundColor = Colors.Dark.green
      cell.showNotes = episode.notes!
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.SongCellReuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
      cell.backgroundColor = UIColor.clearColor()
      cell.song = episode.songs![indexPath.row - episode.numberOfNotesCells]
      return cell
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Recent songs"
  }

  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.contentView.backgroundColor = Colors.Dark.green
    header.textLabel?.textColor = UIColor.whiteColor()
    header.textLabel?.font = UIFont(name: "Lato-Black", size: 14)!
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    // Necessary to enable the edit actions at all
  }

  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let favButton = UITableViewRowAction(style: .Default, title: "Favorite") {
      _, inxPth in
      let song = self.episode.songs![inxPth.row - self.episode.numberOfNotesCells]
      self.delegate.radio!.favourites.append(Favourite(song: song, episode: self.episode))
      tableView.editing = false
    }
    favButton.backgroundColor = Colors.Light.watermelon

    return [favButton]
  }
}
