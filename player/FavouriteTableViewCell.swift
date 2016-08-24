//
//  FavouriteTableViewCell.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 3/1/15.
//  Copyright (c) 2015 Cameron Bothner. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {
  var p: Favourite? {
    didSet {
      updateUI()
    }
  }

  @IBOutlet weak var songLabel: UILabel!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var timeAndShowLabel: UILabel!
  @IBOutlet weak var albumLabel: UILabel!
  @IBOutlet weak var copyrightLabel: UILabel!


  func updateUI() {
    if let p = self.p {
      timeAndShowLabel?.text = "\(p.song.longAt) — \(p.episode.name) w/ \(p.episode.dj)"
      artistLabel?.text = "\(p.song.artist):"
      songLabel?.text = "“\(p.song.name)”"
      if (p.song.album != "") { albumLabel?.text = p.song.album}
      if p.song.label != "" {
        if let year = p.song.year where year != 0 {
          copyrightLabel?.text = "(\(p.song.label), \(year))"
        } else {
          copyrightLabel?.text = "(\(p.song.label))"
        }
      }
    }
  }


  override func awakeFromNib() {
    super.awakeFromNib()
    timeAndShowLabel?.text = "—"
    artistLabel?.text = "—"
    songLabel?.text = "—"
    albumLabel?.text = "—"
    copyrightLabel?.text = ""
    artistLabel?.font = UIFont(name: "Lato-Black", size: 16.0)
  }

}
