//
//  ShowDetailViewController.swift
//  player
//
//  Created by Cameron Bothner on 3/31/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit

class ShowDetailViewController: UIViewController,
UITableViewDelegate, UITableViewDataSource,
UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

  var show = Show()

  @IBOutlet weak var showDescription: UITextView!
  @IBOutlet var djs: UICollectionView!
  @IBOutlet weak var djsHeight: NSLayoutConstraint!
  @IBOutlet var recentEpisodes: UITableView!
  @IBOutlet weak var recentEpisodesHeight: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()

    if show.episodes == nil {
      fetchShowInfo()
    }

    showDescription.layoutManager.hyphenationFactor = 1.0
    showDescription.sizeToFit()
    showDescription.text = show.description

    djs.allowsSelection = true

    recentEpisodes.estimatedRowHeight = recentEpisodes.rowHeight
    recentEpisodes.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let bar = self.navigationController?.navigationBar
    bar?.barTintColor = Colors.Dark.orange
    bar?.tintColor = UIColor.whiteColor()
    bar?.titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "Lato-Black", size: 17)!,
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
    if let navController = self.navigationController as? LightStatusBarNavigationController {
      navController.light = true
    }
    djs.reloadData()
    recentEpisodes.reloadData()
  }

  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    djsHeight.constant = djs.contentSize.height
    recentEpisodesHeight.constant = recentEpisodes.contentSize.height
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - DJs
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return show.djs.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DJ", forIndexPath: indexPath) as! DJCollectionViewCell
    let djName = show.djs[indexPath.row].name
    cell.nameLabel.text = djName

    djsHeight.constant = djs.contentSize.height
    return cell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let label = UILabel()
    label.text = show.djs[indexPath.row].name
    label.font = UIFont(name: "Lato-Black", size: 15.0)
    let size = label.intrinsicContentSize()
    return CGSizeMake(size.width + 32, size.height + 24)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let djVC = storyboard?.instantiateViewControllerWithIdentifier("DJ") as! DJViewController
    djVC.dj_path = show.djs[indexPath.row].path
    djVC.title = show.djs[indexPath.row].name
    navigationController?.pushViewController(djVC, animated: true)
  }

  // MARK: - Recent Episodes

  func shouldDisplayDJName(inCellForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return show.djs.count > 1 || show.episodes![indexPath.row].dj != show.djs.first?.name
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("RecentEpisode", forIndexPath: indexPath) as! RecentEpisodeTableViewCell
    let episode = show.episodes![indexPath.row]
    cell.at.text = episode.at

    let conditionalDJName: String
    if self.shouldDisplayDJName(inCellForRowAtIndexPath: indexPath) {
      conditionalDJName = "with \(episode.dj)"
    } else { conditionalDJName = "" }
    cell.withString?.text = conditionalDJName

    let detailText: String
    if episode.beginning?.compare(NSDate()) == .OrderedDescending {
      detailText = "—"
    } else {
      detailText = "\(episode.songs?.count ?? 0) song\(episode.songs?.count != 1 ? "s" : "")"
    }
    cell.songsCount?.text = detailText

    cell.backgroundColor = UIColor.clearColor()

    recentEpisodesHeight.constant = recentEpisodes.contentSize.height

    return cell
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Recent Episodes"
  }

  func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.contentView.backgroundColor = Colors.Dark.orange
    header.textLabel?.textColor = UIColor.whiteColor()
    header.textLabel?.font = UIFont(name: "Lato-Black", size: 14)!
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return show.episodes?.count ?? 0
  }

  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    let e = show.episodes![indexPath.row]
    if e.beginning?.compare(NSDate()) == .OrderedDescending { return nil }
    return indexPath
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let vc = storyboard?.instantiateViewControllerWithIdentifier("Playlist") as! PlaylistTableViewController
    vc.episode = show.episodes![indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
  }

  // MARK: - Networking

  private func fetchShowInfo() {
    let background_qos = Int(QOS_CLASS_BACKGROUND.rawValue)
    dispatch_async(dispatch_get_global_queue(background_qos, 0)) {
      let playlist_api_url = self.show.url
      if let data = NSData(contentsOfURL: playlist_api_url) {
        dispatch_async(dispatch_get_main_queue()) {
          let json = JSON(data: data)

          var episodes: [Episode] = []

          for (_, ep) : (String, JSON) in json["episodes"] {
            var songs: [Song] = []
            for (_, s) : (String, JSON) in ep["songs"] {
              let song = Song(
               artist:   s["artist"].stringValue,
               name:     s["name"].stringValue,
               album:    s["album"].stringValue,
               label:    s["label"].stringValue,
               year:     s["year"].int,
               request:  s["request"].boolValue,
               timestamp:s["at"].dateTime
              )
              songs.append(song)
            }

            let episode = Episode(
              name:  ep["name"].stringValue,
              dj:    ep["dj"].stringValue,
              beginning: ep["beginning"].dateTime,
              ending: ep["ending"].dateTime,
              notes: ep["show_notes"].string,
              songs: songs.reverse()
            )
            episodes.append(episode)
          }

          self.show.episodes = episodes
          self.recentEpisodes.reloadData()
        }
      }
    }
  }
}
