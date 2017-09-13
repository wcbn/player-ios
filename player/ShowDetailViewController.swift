//
//  ShowDetailViewController.swift
//  player
//
//  Created by Cameron Bothner on 3/31/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShowDetailViewController: UIViewController,
UITableViewDelegate, UITableViewDataSource,
UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

  var show = Show()
  var semesterName = ""

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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let bar = self.navigationController?.navigationBar
    bar?.barTintColor = Colors.Dark.orange
    bar?.tintColor = UIColor.white
    bar?.titleTextAttributes = [
      NSAttributedStringKey.font.rawValue: UIFont(name: "Lato-Black", size: 17)!,
      NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
    ]
    if let navController = self.navigationController as? LightStatusBarNavigationController {
      navController.light = true
    }
    djs.reloadData()
    recentEpisodes.reloadData()
  }

  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    djsHeight.constant = djs.contentSize.height
    recentEpisodesHeight.constant = recentEpisodes.contentSize.height
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - DJs
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return show.djs.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DJ", for: indexPath) as! DJCollectionViewCell
    let djName = show.djs[indexPath.row].name
    cell.nameLabel.text = djName

    djsHeight.constant = djs.contentSize.height
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let label = UILabel()
    label.text = show.djs[indexPath.row].name
    label.font = UIFont(name: "Lato-Black", size: 15.0)
    let size = label.intrinsicContentSize
    return CGSize(width: size.width + 32, height: size.height + 24)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let djVC = storyboard?.instantiateViewController(withIdentifier: "DJ") as! DJViewController
    djVC.dj_path = show.djs[indexPath.row].path
    djVC.title = show.djs[indexPath.row].name
    navigationController?.pushViewController(djVC, animated: true)
  }

  // MARK: - Recent Episodes

  func shouldDisplayDJName(inCellForRowAtIndexPath indexPath: IndexPath) -> Bool {
    return show.djs.count > 1 || show.episodes![indexPath.row].dj != show.djs.first?.name
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecentEpisode", for: indexPath) as! RecentEpisodeTableViewCell
    let episode = show.episodes![indexPath.row]
    cell.at.text = episode.at

    let conditionalDJName: String
    if self.shouldDisplayDJName(inCellForRowAtIndexPath: indexPath) {
      conditionalDJName = "with \(episode.dj)"
    } else { conditionalDJName = "" }
    cell.withString?.text = conditionalDJName

    let detailText: String
    if episode.beginning?.compare(Date()) == .OrderedDescending {
      detailText = "—"
    } else {
      detailText = "\(episode.songs?.count ?? 0) song\(episode.songs?.count != 1 ? "s" : "")"
    }
    cell.songsCount?.text = detailText

    cell.backgroundColor = UIColor.clear

    let selectionColor = UIView()
    selectionColor.backgroundColor = UIColor.white
    cell.selectedBackgroundView = selectionColor

    recentEpisodesHeight.constant = recentEpisodes.contentSize.height

    return cell
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Recent Episodes"
  }

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.contentView.backgroundColor = Colors.Dark.orange
    header.textLabel?.textColor = UIColor.white
    header.textLabel?.font = UIFont(name: "Lato-Black", size: 14)!
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return show.episodes?.count ?? 0
  }

  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    let e = show.episodes![indexPath.row]
    if e.beginning?.compare(Date()) == .OrderedDescending { return nil }
    return indexPath
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "Playlist") as! PlaylistTableViewController
    vc.episode = show.episodes![indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
  }

  // MARK: - Networking

  fileprivate func fetchShowInfo() {
    fetch(dataFrom: show.url) { json in
      self.show.episodes = json["episodes"].arrayValue.map { episode in
        return Episode(fromJSON: episode)
      }
      self.recentEpisodes.reloadData()
    }
  }
}
