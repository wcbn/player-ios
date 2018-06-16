//
//  ShowNotesTableViewCell.swift
//  player
//
//  Created by Cameron Bothner on 3/26/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class ShowNotesTableViewCell: UITableViewCell {

  var showNotes: NSAttributedString? = nil {
    didSet {
      updateUI()
    }
  }

  @IBOutlet weak var notes: UILabel!

  func updateUI() {
    notes?.attributedText = showNotes ?? NSAttributedString()
  }

}
