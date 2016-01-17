//
//  FavouriteTableViewCell.swift
//  wcbnRadio
//
//  Created by Cameron Bothner on 3/1/15.
//  Copyright (c) 2015 Cameron Bothner. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {
    var song: Song? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!

    func updateUI() {
        showLabel?.text = nil
        songLabel?.text = nil
        artistLabel?.text = nil

        if let song = self.song {
            showLabel?.text = song.show
            songLabel?.text = song.title
            artistLabel?.text = song.artist
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
