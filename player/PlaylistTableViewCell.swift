//
//  PlaylistTableViewCell.swift
//  player
//
//  Created by Cameron Bothner on 3/25/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
  var song: Song? {
    didSet {
      updateUI()
    }
  }

  @IBOutlet weak var timestampLabel: UILabel!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var songLabel: UILabel!
  @IBOutlet weak var albumLabel: UILabel!
  @IBOutlet weak var copyrightLabel: UILabel!


  func updateUI() {
    if let song = self.song {
      timestampLabel?.text = song.at
      artistLabel?.text = "\(song.artist):"
      songLabel?.text = "“\(song.name)”"
      if (song.album != "") { albumLabel?.text = song.album}
      if song.label != "" {
        if let year = song.year {
          copyrightLabel?.text = "(\(song.label), \(year))"
        } else {
          copyrightLabel?.text = "(\(song.label))"
        }
      }
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    timestampLabel?.text = "—"
    artistLabel?.text = "—"
    songLabel?.text = "—"
    albumLabel?.text = "—"
    copyrightLabel?.text = ""
    artistLabel?.font = UIFont(name: "Lato-Black", size: 16.0)
  }

}
