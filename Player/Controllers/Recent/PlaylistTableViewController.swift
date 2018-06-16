//
//  PlaylistTableViewController.swift
//  player
//
//  Created by Cameron Bothner on 1/17/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController {

  let delegate = UIApplication.shared.delegate as! AppDelegate
  var episode = Episode()

  fileprivate struct Storyboard {
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
    djButton.setTitle("\(episode.dj) ›", for: .normal)
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

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    let notificationCenter = NotificationCenter.default
    let mainQueue = OperationQueue.main
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "SongDataReceived"),
                                          object: nil,
                                          queue: mainQueue)
    { _ in
      self.updateUI()
    }

    updateUI()

    // cell height
    tableView.estimatedRowHeight = tableView.rowHeight
    tableView.rowHeight = UITableViewAutomaticDimension

    setTitleBarColor()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setTitleBarColor()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
  }

  @IBAction func openDJ() {
    let djVC = storyboard?.instantiateViewController(withIdentifier: "DJ") as! DJViewController
    djVC.dj_path = episode.dj_path
    djVC.title = episode.dj
    navigationController?.pushViewController(djVC, animated: true)
  }

  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episode.numberOfNotesCells + (episode.songs?.count ?? 0)
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.row == 0 && episode.notes != nil && episode.notes != "") {
      let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ShowNotesCellReuseIdentifier, for: indexPath) as! ShowNotesTableViewCell
      cell.backgroundColor = Colors.Dark.green
      cell.showNotes = MD.toAttributedString(episode.notes!)
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.SongCellReuseIdentifier, for: indexPath) as! PlaylistTableViewCell
      cell.backgroundColor = UIColor.clear
      cell.song = episode.songs![indexPath.row - episode.numberOfNotesCells]
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if episode.notes != nil { return nil }
    if self == navigationController?.viewControllers[0] {
      return "Recent Songs"
    } else {
      return "All Songs"
    }
  }

  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.contentView.backgroundColor = Colors.Dark.green
    header.textLabel?.textColor = UIColor.white
    header.textLabel?.font = UIFont(name: "Lato-Black", size: 14)!
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    // Necessary to enable the edit actions at all
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let favButton = UITableViewRowAction(style: .default, title: "Favorite") {
      _, inxPth in
      let song = self.episode.songs![inxPth.row - self.episode.numberOfNotesCells]
      self.delegate.radio!.favourites.append(Favourite(song: song, episode: self.episode))
      tableView.isEditing = false
    }
    favButton.backgroundColor = Colors.Light.watermelon

    return [favButton]
  }
}

// MARK: - ColoredTitleBar
extension PlaylistTableViewController: ColoredTitleBar {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent

  }
  var titleBarColor: UIColor { return Colors.Dark.green }
  var titleBarDark: Bool { return true }
}
