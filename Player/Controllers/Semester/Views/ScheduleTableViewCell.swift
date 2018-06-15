//
//  ScheduleTableViewCell.swift
//  player
//
//  Created by Cameron Bothner on 3/27/16.
//  Copyright © 2016 WCBN-FM Ann Arbor. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

  var show = Show() {
    didSet {
      updateUI()
    }
  }

  @IBOutlet weak var timesLabel: UILabel!
  @IBOutlet weak var showNameLabel: UILabel!
  @IBOutlet weak var withLabel: UILabel!

  func updateUI() {
    timesLabel?.text = show.times
    showNameLabel?.text = show.name
    withLabel?.text = show.with
  }

}
